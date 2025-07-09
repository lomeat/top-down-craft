[Назад](./README.md)

## Инвентарь и Drag & Drop

Инвентарь НАВСЕГДА имеет структуру словаря. Ну, может и не навсегда, но мне нравится дать возможность игроку носить с собой хоть 4000 камня в одной ячейке без ограничений (ну, кроме int32). Но делить его на стаки нельзя. Заняты слоты? Выгрузи в сундук. Которого еще нет, хахах...

Вот у меня есть inv_slot_ui, inv_ui. А еще есть inv_data, где манипулируются данные. По сути в UI нет никакой логики расположения предметов, кроме того, что при ререндере инвентаря, все слоты заполняются итеративно по данным инвентаря. У них нет специальных идексов, хотя по сути это просто массив слотов.

Что если для слотов сделать тоже какуюто структуру данных? Например Dictionary, где ключи это индексы слота?

Если ключи, то это:

```gdscript
var slots = {
	1: { item: some_item, count: 12 },
	2: { item: some_item, count: 12 },
}

func get_slot(id: int) -> slot:
	slots[id]

func add(item, count):
	for id in slots:
		if id == "empty":
			id = item.id
			slots.id = { item, count }
```

Тогда в логике перемещения я бы делал:

```gdscript
if id != "empty":
	slots.remove(id)

if id == "empty":
	return
```

А при отпускании я бы делал чтото типа:

```gdscript
if id != "empty":
	slots.remove(id)
	slots.add(item, count)

if id == "empty":
	slots.add(item, count)
```

**Вопрос все еще открыт, я не решил**

## Так, мысль такая

```
drag_started

if slot was clicked
    - inv does not change
    - slot clear
    - drag item setup

drop_to_slot

if slot was clicked:
    - inv set item to new slot
    - inv remove item from old slot
drag_ended (true)

if in slot was item when slot was clicked:
    - inv set item to item 2 slot
    - inv remove item from old slot
    - drag state setup
drag_ended (true)
drag_started

if drag was canceled:
    - inv does not change
    - drag state reset
drag_ended (false)
```

![logic](<images/CleanShot 2025-07-09 at 09.43.56@2x.jpg>)
