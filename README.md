# StudentLK

MVP Flutter-приложения "Личный кабинет студента" для ГАПОУ СО "Новоузенский агротехнологический техникум".

## Что уже есть

- экран входа для студента и администратора;
- главный экран студента с расписанием на сегодня и объявлениями;
- раздел расписания по дням недели;
- раздел объявлений с фильтром важных сообщений;
- профиль студента;
- простая панель администратора;
- добавление пары и объявления в демо-хранилище;
- подготовка к Supabase через `supabase_flutter`;
- SQL-схема MVP в `supabase/mvp_schema.sql`.

## Запуск

```bash
flutter pub get
flutter run
```

Для web-проверки:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5174
```

## Supabase

Приложение уже инициализирует Supabase, если передать ключи:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

На текущем этапе интерфейс работает на демо-данных, чтобы MVP можно было смотреть без настроенной базы. Следующий шаг разработки: заменить `AppStore.demo()` на репозиторий, который читает и сохраняет данные в таблицы Supabase.

## Проверка

```bash
flutter analyze
flutter test
```
