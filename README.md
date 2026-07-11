# WD2Launcher

Watch Dogs 2 Launcher с автоматическим обходом EAC и установкой трейнера.

## Что делает

1. Находит Watch Dogs 2 в Steam
2. Устанавливает параметр запуска `-eac_launcher` (отключает EAC)
3. Устанавливает ScriptHook + Lua трейнер в папку игры
4. Запускает игру через Steam

## Установка

1. Скачай релиз из [Releases](../../releases)
2. Распакуй рядом с папкой `Tools/trainer/`
3. Запусти `WD2Launcher.exe`
4. Наслаждайся игрой с трейнером (F4 в игре)

## Сборка

```bash
dotnet build --configuration Release
```

## Трейнер (F4 в игре)

### Player
- God Mode (бессмертие)
- Unlimited Ammo
- Noclip / Fly
- Оружие
- Управление розыском
- Деньги и фолловеры

### Vehicle
- Спавн 247 моделей транспорта
- Spider Tank
- Починка, двигатель, сирена
- Фары, поворотники, номера
- Детали кузова

### Environment
- Время суток
- Погода
- Blackout (выключить электричество)
- Power Glitch
- Светофоры

### Camera
- FreeCam
- Скрытие HUD

### Clothing
- Смена модели (Wrench, Sitara и др.)
- Разблокировка всей одежды

### Inventory
- Предметы, эмоции
- Подключение к дрону/RC-машинке

## Лицензия

MIT
