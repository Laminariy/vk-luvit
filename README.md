# vk-luvit
Библиотека для работы с VK API.

Основана на [luvit](https://luvit.io/).

### Преимущества:

* Работает на любой версии VK API.
* Полностью асинхронна.
* Умеет оптимизировать запросы к VK API.
* Умеет использовать несколько токенов.

### Установка:

- Для начала нужно [установить](https://luvit.io/install.html) luvit.
- Затем необходимо выполнить команду
```shell
lit install Laminariy/vk-luvit
```

---

## Пример:

```lua
local Bot = require("vk-luvit").Bot


local bot = Bot('Your token')

bot.on.message_new(function(event)
  bot.api.messages.send({
    peer_id = event.message.from_id,
    random_id = 0,
    message = event.message.text
  })
end)

bot:run()
```
---

## VK Reference:

### `VK(token[, version])`

Создает и возвращает объект для запросов к VK API.

**Параметры**

- `token` <kbd>string|table</kbd> Токен или список токенов для взаимодействия. Если указать список токенов, то они будут использоваться по очереди.
- `version` <kbd>string</kbd> (_optional_) Версия VK API. По умолчанию '5.131'.

### vk:request(method[, params])
### vk(method[, params])

Совершает запрос к VK API.
Возвращает результат запроса, если он успешен, либо nil и ошибку.

Подробности о всех методах VK API [здесь](https://dev.vk.com/method)

**Параметры**

- `method` <kbd>string</kbd> Название метода который необходимо исполнить.
- `params` <kbd>table</kbd> (_optional_) Таблица параметров запроса.

## API Reference:

### `API(options)`

Создает и возвращает объект-обертку над VK. Позволяет использовать синтаксис языка для запросов.

**Параметры**

- `options` <kbd>string|table</kbd> Таблица параметров для апи. Либо строка/список токенов, если нужно оставить настройки по-умолчанию.
- `options.token` <kbd>string|table</kbd> Токен или список токенов для взаимодействия. Если указать список токенов, то они будут использоваться по очереди.
- `options.version` <kbd>string</kbd> (_optional_) Версия VK API. По умолчанию '5.131'.
- `options.queued` <kbd>boolean</kbd> (_optional_) Если true, то все запросы будут собираться в очередь и использовать api.execute для оптимизации количества запросов. Позволяет совершать 500 запросов в секунду на один токен.
По умолчанию - false.

### `api.method([params])`

Выполняет запрос к VK API, где method - название метода. Поддерживается как camelCase так и snake_case.

Подробности о всех методах VK API [здесь](https://dev.vk.com/method)

**Параметры**

- `params` <kbd>table</kbd> (_optional_) Таблица параметров запроса.

**Пример**

```lua
  local API = require('vk-luvit')

  local api = API('Your token')
  -- camelCase
  api.groups.getById()
  -- snake_case
  api.groups.get_by_id()
```

## Bot Reference:

### `Bot(options)`

Создает и возвращает объект-обертку над VK. Позволяет использовать синтаксис языка для запросов.

**Параметры**

- `options` <kbd>string|table</kbd> Таблица параметров для апи. Либо строка/список токенов, если нужно оставить настройки по-умолчанию.
- `options.token` <kbd>string|table</kbd> Токен или список токенов для взаимодействия. Если указать список токенов, то они будут использоваться по очереди.
- `options.version` <kbd>string</kbd> (_optional_) Версия VK API. По умолчанию '5.131'.
- `options.queued` <kbd>boolean</kbd> (_optional_) Если true, то все запросы будут собираться в очередь и использовать api.execute для оптимизации количества запросов. Позволяет совершать 500 запросов в секунду на один токен.
По умолчанию - false.

### `bot:run()`

Запускает бота.

### `bot:stop()`

Останавливает бота. Известный баг: перед остановкой бот может совершить еще один запрос к VK API.

### `bot.api`

Доступ к объекту API бота.

### `bot.on.event_name([filter,] func)`

Подписывает функцию-обработчик на событие от [Bot LongPoll](https://dev.vk.com/api/bots-long-poll/getting-started)
event_name - название события. Со списком всех событий VK API можно ознакомиться [здесь](https://dev.vk.com/api/community-events/json-schema)

Так же доступен особый тип события 'all', который передает все поступившие события в функцию-обработчик.

**Параметры**

- `filter` <kbd>function</kbd> (_optional_) Обрабатывает поступившее событие и передает его функции-обработчику. Сигнатура функции filter(event). Функция должна вернуть результат, который будет обработан функцией-обработчиком, либо nil, если функцию-обработчик не нужно вызывать. По умолчанию используется функция, которая возвращает объект из события.
- `func` <kbd>function</kbd> Функция-обработчик, которая будет вызвана, если фильтр обработал событие и вернул результат, отличный от nil. Сигнатура функции совпадает с результатом функции filter.

## Keyboard Reference:

### `Keyboard([one_time, inline])`

Создает объект клавиатуры.
Подробнее о клавиатурах ботов [здесь](https://dev.vk.com/api/bots/development/keyboard)

**Параметры**

- `one_time` <kbd>boolean</kbd> (_optional_) Если true, клавиатура скроется после первого нажатия.
- `inline` <kbd>boolean</kbd> (_optional_) Если true, клавиатура будет закреплена под сообщением.

### `keyboard:button(action[, color])`

Добавляет кнопку на клавиатуру.

**Параметры**

- `action` <kbd>table</kbd> Объект действия кнопки.
- `color` <kbd>string</kbd> (_optional_) Цвет кнопки.

### `keyboard:row()`

Добавляет ряд кнопок к клавиатуре.

### `keyboard:clear()`

Очищает клавиатуру.

### `keyboard:get()`

Возвращает JSON клавиатуры для отправки вместе с сообщением.
