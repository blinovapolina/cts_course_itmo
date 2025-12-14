# Отчет по CI/CD

Отчет описывает bad и good practices в CI/CD

## Bad Practices и их исправления

### 1. Отсутствие игнорирования изменений файлов

**Bad Practice:**

```yaml
on:
  pull_request:
```

**Плохо:** Нет игнорирования изменений файлов, которые не относятся к основному коду

**Как надо:**

```yaml
on:
  pull_request:
    paths:
      - "lab_3/part_1/**"
      - "!docs/**"
      - "!README.md"
      - "!LICENSE"
```

**Объяснение:** Теперь workflow запускается только при изменении кода, исключая документацию и другие несущественные файлы

---

### 2. Отсутствие матрицы версий Node.js

**Bad Practice:**

```yaml
- name: Set up Node.js 24
  uses: actions/setup-node@v4
  with:
    node-version: 24
```

**Плохо:** Тесты выполняются только на одной версии Node.js, что не гарантирует совместимость с другими версиями

**Как надо:**

```yaml
strategy:
  matrix:
    node-version: ["20", "24"]
steps:
  - name: Set up Node.js ${{ matrix.node-version }}
    uses: actions/setup-node@v4
    with:
      node-version: ${{ matrix.node-version }}
```

**Объяснение:** Теперь тесты выполняются на нескольких версиях Node.js (20 и 24)

---

### 3. Отсутствие кэширования зависимостей

**Bad Practice:**

```yaml
steps:
  - uses: actions/checkout@v4
```

**Плохо:** При каждом запуске workflow зависимости устанавливаются заново, что увеличивает время выполнения

**Как надо:**

```yaml
- name: Cache node modules
  uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ matrix.node-version }}-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-${{ matrix.node-version }}-

- name: Set up Node.js ${{ matrix.node-version }}
  uses: actions/setup-node@v4
  with:
    node-version: ${{ matrix.node-version }}
    cache: "npm"
```

**Объяснение:**

- Кэширование через `actions/cache@v4` для директории `~/.npm`
- Дополнительное кэширование через встроенный механизм `setup-node` с параметром `cache: "npm"`
- Ключ кэша зависит от версии Node.js и хеша `package-lock.json`
- Как итог: значительное сокращение времени установки зависимостей

---

## Тестовый код

Для тестирования ci/cd был написан простой калькулятор на js и 3 маленьких теста

```js
const calculate = (a, b) => {
  return a + b;
};

export { calculate };
```
---

## Запуск
Результат выполнения тестов
<img width="1540" height="554" alt="image" src="https://github.com/user-attachments/assets/cda78201-4914-475a-8a5d-72ad5993af49" />
<img width="971" height="339" alt="image" src="https://github.com/user-attachments/assets/b439c115-4827-42ea-82b6-3a8f28f159a9" />

## Конец
<img width="768" height="398" alt="image" src="https://github.com/user-attachments/assets/7a69b5a2-0200-48ca-9168-735879d6f3ea" />

