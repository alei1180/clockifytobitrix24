﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьКоличествоПолучаемыхЗаписей();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПересчитатьПодвал();
	УстановитьВидомостьОшибок();
	ЗаполнитьБитриксСписокЗадач();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыбратьПользователяБитрикс(Команда)
	
	Если НЕ ЗначениеЗаполнено(Bitrix24WebHook) Тогда
		СообщитьПользователю("Для выбора пользователя необходимо сначала заполнить Bitrix WebHook", Неопределено, "Bitrix24WebHook");
		Возврат;
	КонецЕсли;
	
	Подсказка = "Введите ID пользователя Битрикс";
	Оповещение = Новый ОписаниеОповещения("ПослеВводаIDПользователяБитрикс", ЭтотОбъект, Новый Структура());
	ПоказатьВводЧисла(Оповещение, 0, Подсказка, 10, 0);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьВремяClockify(Команда)
	
	ОчиститьСообщения();
	ОчиститьЗатраченноеВремя();
	ФильтрПоНевыгруженнымВБитрикс = 0;
	
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	ПолучитьДанныеОЗатраченномВремени();
	
	ЗаполнитьБитриксСписокЗадач();
	ПересчитатьПодвал();
	УстановитьВидомостьОшибок();
		
КонецПроцедуры

&НаКлиенте
Процедура ЭкспортироватьВремяВБитрикс(Команда)
	
	ОчиститьСообщения();
		
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
		
	НеВыгруженныеЗадачи = ЗатраченноеВремя.НайтиСтроки(Новый Структура("УчтеноВБитрикс", Ложь));	
	Если ЗначениеЗаполнено(НеВыгруженныеЗадачи) Тогда
		КоличествоЗаписейДляЗагрузки = ЗатраченноеВремя.НайтиСтроки(Новый Структура("УчтеноВБитрикс", Ложь)).Количество();
		ТекстВопроса = СтрШаблон("Вы хотите загрузить %1 записей в Битрикс24.%2Продолжить?",
												  КоличествоЗаписейДляЗагрузки, Символы.ПС);
		
		Оповещение = Новый ОписаниеОповещения("ПослеВопросаОЗагрузкеВремениВБитрикс", ЭтотОбъект, Новый Структура());
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Ошибки) Тогда
		ТекстСообщения = "Есть записи с ошибками, их выгрузка не возможна. Сначала исправьте ошибки в Clockify.";
		СообщитьПользователю(ТекстСообщения, Неопределено, Неопределено);
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ЗатраченноеВремя) И НЕ ЗначениеЗаполнено(НеВыгруженныеЗадачи) Тогда
		ТекстСообщения = "Все записи о времени уже выгружены в Битрикс24";
		СообщитьПользователю(ТекстСообщения, Неопределено, Неопределено);
		Возврат;
	КонецЕсли;
	
	СообщитьПользователю("Нечего выгружать", Неопределено, Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьНастройкиВФайл(Команда)
	
	Оповещение = Новый ОписаниеОповещения("ВыборКаталогаДляСохраненияЗавершение", ЭтотОбъект);
	ДиалогОткрытия = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	ДиалогОткрытия.Заголовок = "Выберите каталог";
	ДиалогОткрытия.Показать(Оповещение)
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьНастройкиИзФайла(Команда)
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Фильтр = "Текстовый документ (*.ini)|*.ini";
	Диалог.Заголовок = "Выберите текстовый документ";
	ОповещениеЗавершения = Новый ОписаниеОповещения("ВыборФайлаНастроекЗавершение", ЭтотОбъект);
	Диалог.Показать(ОповещениеЗавершения);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ФильтрПоНевыгруженнымВБитриксПриИзменении(Элемент)
	
	ЗатраченноеВремяУстановитьОтборСтрок();
	ПересчитатьПодвал();
	
КонецПроцедуры

&НаКлиенте
Процедура БитриксСписокЗадачПриИзменении(Элемент)
	
	ЗатраченноеВремяУстановитьОтборСтрок();
	ПересчитатьПодвал();
	
КонецПроцедуры

&НаКлиенте
Процедура БитриксСписокЗадачАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	ИскомыйТекст = ВРег(Текст);
	Пока СтрНайти(ИскомыйТекст, "  ") > 0 Цикл
		ИскомыйТекст = СтрЗаменить(ИскомыйТекст, "  ", " ");
	КонецЦикла;
	
	ИскомыйТекст = СокрЛП(ИскомыйТекст);
	ДлинаТекста = СтрДлина(ИскомыйТекст);
	Если ДлинаТекста = 0 Тогда
		Возврат
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	
	Шрифт = Новый Шрифт(,,Истина);
	Цвет = WebЦвета.Зеленый;
	
	ДанныеВыбора = Новый СписокЗначений;
	
	Подстроки = СтрРазделить(ИскомыйТекст, " ");
	
	Для Каждого Стр Из Элемент.СписокВыбора Цикл
		
		Строка = Стр.Значение;
		СтрокаВРег = ВРег(Строка);
		
		ВхожденияНайдены = Истина;
		
		Для Каждого Подстрока Из Подстроки Цикл
			Если Найти(СтрокаВРег, Подстрока) = 0 Тогда
				ВхожденияНайдены = Ложь;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если Не ВхожденияНайдены Тогда
			Продолжить
		КонецЕсли;
		
		ДлинаСтроки = СтрДлина(Строка);
		Массив = Новый Массив(ДлинаСтроки);
		
		Для Каждого Подстрока Из Подстроки Цикл
			ДлинаПодстроки = СтрДлина(Подстрока);
			НачалоПоиска = 1;
			Пока Истина Цикл
				
				ПозицияПодстроки = СтрНайти(СтрокаВРег, Подстрока, , НачалоПоиска);
				Если ПозицияПодстроки = 0 Тогда
					Прервать;
				КонецЕсли;
				
				НачалоПоиска = ПозицияПодстроки + ДлинаПодстроки;
				
				Для Сч = ПозицияПодстроки По НачалоПоиска - 1 Цикл
					Массив[Сч - 1] = Истина;
				КонецЦикла;
				
				Если НачалоПоиска > ДлинаСтроки Тогда
					Прервать;
				КонецЕсли;
				
			КонецЦикла;
		КонецЦикла;
		
		МассивСтрок = Новый Массив;
		Для Сч = 0 По Массив.ВГраница() Цикл
			Символ = Сред(Строка, Сч + 1, 1);
			Если Массив[Сч] = Неопределено Тогда
				МассивСтрок.Добавить(Символ);
			Иначе
				МассивСтрок.Добавить(Новый ФорматированнаяСтрока(Символ, Шрифт, Цвет));
			КонецЕсли;
		КонецЦикла;
		
		ДанныеВыбора.Добавить(Строка, Новый ФорматированнаяСтрока(МассивСтрок));
		
		Если ДанныеВыбора.Количество() = 50 Тогда
			Прервать
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияСведенияОбОбработкеНажатие(Элемент)
	
	ОткрытьФорму("ВнешняяОбработка.ClockifyToBitrix24.Форма.СведенияОбОбработке",,ЭтаФорма,,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьКоличествоПолучаемыхЗаписей()
	
	ClockifyPageSize = 300;
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьЗатраченноеВремя()
	
	ЗатраченноеВремя.Очистить();
	ПересчитатьПодвал();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТЗЗатраченноеВремя(ClockifyДанныеПоЗатраченномуВремени, БитриксЗатраченноВремя, МассивНомеровЗадач)
	
	Ошибки.Очистить();
	
	ТЗНазваниеЗадачБитрикс = НазваниеЗадачБитрикс(МассивНомеровЗадач);
	Если НЕ ЗначениеЗаполнено(ТЗНазваниеЗадачБитрикс) Тогда
		СообщитьПользователю("В комментариях по затраченному времени Clockify, не указано ни одного номера задачи", Неопределено, Неопределено);
		Возврат;
	КонецЕсли;
	
	МассивАктуальныхНомеровЗадач = ТЗНазваниеЗадачБитрикс.ВыгрузитьКолонку("НомерЗадачи");
	
	Для Каждого ClockifyДанные Из ClockifyДанныеПоЗатраченномуВремени Цикл
		
		Если ПропуститьЗапись(ClockifyДанные.description,
							  ClockifyДанные.timeInterval.start,
							  ClockifyДанные.timeInterval.end,
							  МассивАктуальныхНомеровЗадач,
							  Истина) Тогда
			Продолжить;
		КонецЕсли;
		
		СтрЗатраченоеВремя = ЗатраченноеВремя.Добавить();
		
		ДатаНачала = ПрочитатьДатуJSON(ClockifyДанные.timeInterval.start, ФорматДатыJSON.ISO);
		ДатаОкончания = ПрочитатьДатуJSON(ClockifyДанные.timeInterval.end, ФорматДатыJSON.ISO);
		ПотраченоСекунд = ДатаОкончания - ДатаНачала;
		ПотраченоВремени = СтрЗатраченоеВремя.ЗатраченоеВремя + ПотраченоСекунд;
		БЗНомер = СокрЛП(СтрРазделить(ClockifyДанные.description, " ", Ложь)[0]);
		Комментарий = СокрЛП(Прав(ClockifyДанные.description, СтрДлина(ClockifyДанные.description) - СтрДлина(БЗНомер)));
		
		СтрЗатраченоеВремя.Дата = ДатаНачала;
		СтрЗатраченоеВремя.ДатаНачала = ДатаНачала;
		СтрЗатраченоеВремя.ДатаОкончания = ДатаОкончания;
		СтрЗатраченоеВремя.ЗатраченоСекунд = ПотраченоСекунд;
		СтрЗатраченоеВремя.ЗатраченоеВремя = ПотраченоВремени;
		СтрЗатраченоеВремя.Комментарий = Комментарий;
		
		ОтборВремяБитрикс = Новый Структура;
		ОтборВремяБитрикс.Вставить("ДатаСоздания", ДатаНачала);
		ОтборВремяБитрикс.Вставить("Секунды", ПотраченоСекунд);
		НайденноеВремяБитрикс = БитриксЗатраченноВремя.НайтиСтроки(ОтборВремяБитрикс);
		
		СтрЗатраченоеВремя.УчтеноВБитрикс = ЗначениеЗаполнено(НайденноеВремяБитрикс);
		
		НомерЗадачи = СокрЛП(СтрРазделить(ClockifyДанные.description, " ", Ложь)[0]);
		СтрТЗНазваниеЗадачБитрикс = ТЗНазваниеЗадачБитрикс.Найти(НомерЗадачи, "НомерЗадачи");
		Если НЕ СтрТЗНазваниеЗадачБитрикс = Неопределено Тогда
			СтрЗатраченоеВремя.НомерЗадачи = СтрТЗНазваниеЗадачБитрикс.НомерЗадачи;
			СтрЗатраченоеВремя.НазваниеЗадачи = СтрТЗНазваниеЗадачБитрикс.НазваниеЗадачи;
		КонецЕсли;
		
	КонецЦикла;
	
	ЗатраченноеВремя.Сортировать("НазваниеЗадачи Возр, Дата УБЫВ");
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьДанныеОЗатраченномВремени()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	ClockifyДанныеПользователя = ОбработкаОбъект.Clockify_ДанныеПользователя(ClockifyAPIkey);
	Если НЕ ClockifyДанныеПользователя.Свойство("activeWorkspace") ИЛИ НЕ ClockifyДанныеПользователя.Свойство("id") Тогда
		Возврат;
	КонецЕсли;
	
	ClockifyДанныеПоЗатраченномуВремени = ОбработкаОбъект.Clockify_ДанныеПоЗатраченномуВремени(ClockifyAPIkey,
																							   ClockifyДанныеПользователя["activeWorkspace"],
																							   ClockifyДанныеПользователя["id"],
																							   ClockifyPageSize);
	Если НЕ ЗначениеЗаполнено(ClockifyДанныеПоЗатраченномуВремени) Тогда
		СообщитьПользователю("Время clockify не удалось получить.", Неопределено, Неопределено);
		Возврат;
	КонецЕсли;
	
	МассивНомеровЗадач = НомераЗадачБитрикс(ClockifyДанныеПоЗатраченномуВремени);
	
	БитриксЗатраченноеВремя = Новый ТаблицаЗначений;
	
	Для Каждого НомерЗадачиБитрикс Из МассивНомеровЗадач Цикл
		
		ОбработкаОбъект.Bitrix_Задача_ПолучитьЗатраченноеВремя(BitrixURL,
															   Bitrix24WebHook,
															   СокрЛП(НомерЗадачиБитрикс),
															   BitrixUserID,
															   Истина,
															   БитриксЗатраченноеВремя);
		
	КонецЦикла;
	
	Если БитриксЗатраченноеВремя = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьТЗЗатраченноеВремя(ClockifyДанныеПоЗатраченномуВремени, БитриксЗатраченноеВремя, МассивНомеровЗадач);
	
КонецПроцедуры

&НаСервере
Функция ВремяДляБитрикс()
	
	ОбщийМассивВремени = Новый Массив;
	
	ИДПользователя = Формат(BitrixUserID, "ЧГ=");
	
	ЗатраченноеВремя.Сортировать("Дата");
	
	Для Каждого СтрЗатраченноеВремя Из ЗатраченноеВремя Цикл
		
		Если СтрЗатраченноеВремя.УчтеноВБитрикс Тогда
			Продолжить;
		КонецЕсли;
		
		НомерЗадачи = СокрЛП(СтрЗатраченноеВремя.НомерЗадачи);
		Если НЕ ЗначениеЗаполнено(НомерЗадачи) Тогда
			Продолжить;
		КонецЕсли;
		
		МассивЗаписи = Новый Массив;
		МассивЗаписи.Добавить(НомерЗадачи);
		
		ДеталиОЗатраченномВремени = Новый Структура;
		ДеталиОЗатраченномВремени.Вставить("SECONDS", СтрЗатраченноеВремя.ЗатраченоСекунд);
		ДеталиОЗатраченномВремени.Вставить("COMMENT_TEXT", СтрЗатраченноеВремя.Комментарий);
		ДеталиОЗатраченномВремени.Вставить("CREATED_DATE", Формат(СтрЗатраченноеВремя.Дата - 3600, "ДФ='yyyy-MM-dd H:mm:ss'"));
		ДеталиОЗатраченномВремени.Вставить("USER_ID", ИДПользователя);
		
		МассивЗаписи.Добавить(ДеталиОЗатраченномВремени);
		МассивЗаписи.Добавить(СтрЗатраченноеВремя.ПолучитьИдентификатор());
		
		ОбщийМассивВремени.Добавить(МассивЗаписи);
		
	КонецЦикла;
	
	ЗатраченноеВремя.Сортировать("Дата УБЫВ");
	
	Возврат ОбщийМассивВремени;
	
КонецФункции

&НаСервере
Процедура ЭкспортироватьВремяВБитриксНаСервере()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	МассивВремениДляБитрикс = ВремяДляБитрикс();
	ЗагруженоВБитрикс = 0;
	НеЗагруженоВБитрикс = 0;
	Для Каждого ЗаписьЗатраченногоВремени Из МассивВремениДляБитрикс Цикл
		
		НомерЗадачи = ЗаписьЗатраченногоВремени[0];
		ДеталиЗаписиОЗатраченномВремени = ЗаписьЗатраченногоВремени[1];
		СтрТЗЗатраченноеВремя = ЗатраченноеВремя.НайтиПоИдентификатору(ЗаписьЗатраченногоВремени[2]);
		
		АйдиДобавленнойЗаписиБитрикс = ОбработкаОбъект.Bitrix_Задача_ДобавитьЗатраченноеВремя(BitrixURL, Bitrix24WebHook, НомерЗадачи, ДеталиЗаписиОЗатраченномВремени);
		Если АйдиДобавленнойЗаписиБитрикс > 0 Тогда
			СтрТЗЗатраченноеВремя.УчтеноВБитрикс = Истина;
			ЗагруженоВБитрикс = ЗагруженоВБитрикс + 1;
		Иначе
			НеЗагруженоВБитрикс = НеЗагруженоВБитрикс + 1;
		КонецЕсли;
		
	КонецЦикла;
	
	ТекстСообщения = СтрШаблон("В Битрикс24 выгружено %1 записей, ошибок при загрузке: %2.",
								ЗагруженоВБитрикс, НеЗагруженоВБитрикс);
	СообщитьПользователю(ТекстСообщения, Неопределено, Неопределено);
	
	Элементы.ЗатраченноеВремяУчтеноВБитрикс.ТекстПодвала = ЗатраченноеВремя.НайтиСтроки(Новый Структура("УчтеноВБитрикс", Ложь)).Количество();
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ЭтоНомерЗадачи(Описание)
	
	Цифры = "0123456789";
	
	Для Сч = 1 По СтрДлина(Описание) Цикл
		ТекСимв = Врег(Сред(Описание, Сч, 1));
		Если НЕ СтрНайти(Цифры, ТекСимв) > 0 Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

// Добавляет в таблицу Ошибки строку с ошибкой
//
// Параметры:
//  ОписаниеЗатраченногоВремени  - Строка - описание по записи полученной из Clockify
//  ДатаНачала  - Дата - Дата создания записи в Clockify
//  ТекстОшибки  - ТекстОшибки - текст ошибки для исправления
//
&НаСервере
Процедура ДобавитьВОшибки(Знач ОписаниеЗатраченногоВремени, Знач ДатаНачала, Знач ТекстОшибки)
	
	СтрОшибки = Ошибки.Добавить();
	
	СтрОшибки.Дата 		  = ДатаНачала;
	СтрОшибки.Комментарий = ОписаниеЗатраченногоВремени;
	СтрОшибки.Ошибка	  = ТекстОшибки;
	
КонецПроцедуры

// Возвращает Истина если запись Clokify не проходит проверку критериев расположенных в теле функции
//
// Параметры:
//  ОписаниеЗатраченногоВремени  - Строка - Комментарий к затраченному времени Clockify
//  ДатаНачала  - Строка - дата старта записи Clockify в формате JSON
//  ДатаОкончания  - Строка - дата окончания записи Clockify в формате JSON
//
// Возвращаемое значение:
//   Булево   - Истина если запись не прошла проверку
//
&НаСервере
Функция ПропуститьЗапись(Знач ОписаниеЗатраченногоВремени,
						 Знач ДатаНачала,
						 Знач ДатаОкончания,
						 МассивАктуальныхНомеровЗадач = Неопределено,
						 ДобавлятьВТаблицуОшибки = Ложь)
	
	ДатаНачала = ПрочитатьДатуJSON(ДатаНачала, ФорматДатыJSON.ISO);
	ДатаЗаписиМеньшеДатыОграничения = ЗначениеЗаполнено(ДатаС) И ДатаНачала < ДатаС;
	Если ДатаЗаписиМеньшеДатыОграничения Тогда
		Возврат Истина;
	КонецЕсли;
	
	
	ТаймерВремениНеОстановлен = НЕ ЗначениеЗаполнено(ДатаОкончания);
	Если ТаймерВремениНеОстановлен Тогда
		
		Если ДобавлятьВТаблицуОшибки Тогда
			ТекстОшибки = "Остановите таймер по текущей записи.";
			ДобавитьВОшибки(ОписаниеЗатраченногоВремени, ДатаНачала, ТекстОшибки);
		КонецЕсли;
		
		Возврат Истина;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ОписаниеЗатраченногоВремени) Тогда
		
		Если ДобавлятьВТаблицуОшибки Тогда
			ТекстОшибки = "Заполните описание к затраченному времени в формате: <номер задачи битрикс><пробел><комментарий>.";
			ДобавитьВОшибки(ОписаниеЗатраченногоВремени, ДатаНачала, ТекстОшибки);
		КонецЕсли;
		
		Возврат Истина;
		
	КонецЕсли;
	
	НомерЗадачиИОписаниеНЕРазделеныПробелом = СтрНайти(ОписаниеЗатраченногоВремени, " ", НаправлениеПоиска.СНачала) = 0;
	Если НомерЗадачиИОписаниеНЕРазделеныПробелом Тогда
		
		Если ДобавлятьВТаблицуОшибки Тогда
			ТекстОшибки = "Заполните описание к затраченному времени в формате: <номер задачи битрикс><пробел><комментарий>.";
			ДобавитьВОшибки(ОписаниеЗатраченногоВремени, ДатаНачала, ТекстОшибки);
		КонецЕсли;
		
		Возврат Истина;
		
	КонецЕсли;
	
	НомерЗадачи = СокрЛП(СтрРазделить(ОписаниеЗатраченногоВремени, " ", Ложь)[0]);
	Если НЕ ЭтоНомерЗадачи(НомерЗадачи) Тогда
		
		Если ДобавлятьВТаблицуОшибки Тогда
			ТекстОшибки = "Заполните описание к затраченному времени в формате: <номер задачи битрикс><пробел><комментарий>.";
			ДобавитьВОшибки(ОписаниеЗатраченногоВремени, ДатаНачала, ТекстОшибки);
		КонецЕсли;
		
		Возврат Истина;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(МассивАктуальныхНомеровЗадач) Тогда
		
		Если МассивАктуальныхНомеровЗадач.Найти(НомерЗадачи) = Неопределено Тогда
			ТекстОшибки = "Укажите верный номер задачи Битрикс24: задача не найдена или недостаточно прав на действия с ней.";
			ДобавитьВОшибки(ОписаниеЗатраченногоВремени, ДатаНачала, ТекстОшибки);
			
			Возврат Истина;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

&НаСервере
Функция НомераЗадачБитрикс(ClockifyДанныеПоЗатраченномуВремени)
	
	МассивНомеровЗадач = Новый Массив;
	
	Для каждого ClockifyДанные Из ClockifyДанныеПоЗатраченномуВремени Цикл
				
		Если ПропуститьЗапись(ClockifyДанные.description,
							  ClockifyДанные.timeInterval.start,
							  ClockifyДанные.timeInterval.end) Тогда
			Продолжить;
		КонецЕсли;
		
		НомерЗадачи = СокрЛП(СтрРазделить(ClockifyДанные.description, " ", Ложь)[0]);	
		Если МассивНомеровЗадач.Найти(НомерЗадачи) = Неопределено Тогда
			МассивНомеровЗадач.Добавить(НомерЗадачи);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат МассивНомеровЗадач;
	
КонецФункции

&НаСервере
Функция НазваниеЗадачБитрикс(МассивНомеровЗадач)
	
	ТЗНазваниеЗадачБитрикс = Новый ТаблицаЗначений;
	
	Если ЗначениеЗаполнено(МассивНомеровЗадач) Тогда
		ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
		ТЗНазваниеЗадачБитрикс = ОбработкаОбъект.Bitrix_Задача_ПолучитьИнформацию(BitrixURL, Bitrix24WebHook, МассивНомеровЗадач, Истина);
	КонецЕсли;
	
	Возврат ТЗНазваниеЗадачБитрикс;
	
КонецФункции

&НаСервере
Процедура ВыбратьПользователяБитриксНаСервере()
	
КонецПроцедуры

&НаСервере
Функция ПользователяБитрикс(Знач ИДПользователяБитрикс)
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	Возврат ОбработкаОбъект.Bitrix_Пользователь(BitrixURL, Bitrix24WebHook, ИДПользователяБитрикс);
	
КонецФункции

&НаКлиенте
Процедура ПослеВводаIDПользователяБитрикс(ИДПользователяБитрикс, Параметры) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ИДПользователяБитрикс) Тогда
		Возврат;
	КонецЕсли;
	
	ПользовательБитрикс = ПользователяБитрикс(ИДПользователяБитрикс);
	Если НЕ ЗначениеЗаполнено(ПользовательБитрикс) Тогда
		ТекстСообщения = СтрШаблон("Не удалось получить пользователя по ID %1", формат(ИДПользователяБитрикс, "ЧГ="));
		СообщитьПользователю(ТекстСообщения, Неопределено, Неопределено);
		Возврат;
	КонецЕсли;
	
	Если НЕ ПользовательБитрикс.ACTIVE Тогда
		ТекстСообщения = СтрШаблон("Пользователь с ID %1 не является активным", формат(ИДПользователяБитрикс, "ЧГ="));
		СообщитьПользователю(ТекстСообщения, Неопределено, Неопределено);
		Возврат;
	КонецЕсли;
	
	ФИО = СокрЛП(СтрШаблон("%1 %2 %3", ПользовательБитрикс.LAST_NAME, ПользовательБитрикс.NAME, ПользовательБитрикс.SECOND_NAME));
	
	ПодтвердитьПользователяБитрикс24(ФИО, ИДПользователяБитрикс);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодтвердитьПользователяБитрикс24(ФИО, ИДПользователяБитрикс)
	
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("ФИО", ФИО);
	ДопПараметры.Вставить("ИДПользователяБитрикс", ИДПользователяБитрикс);
	
	Оповещение = Новый ОписаниеОповещения("ПослеПодтвержденияПользователя", ЭтотОбъект, ДопПараметры);
	ТекстВопроса = СтрШаблон("%1, это Вы?", ФИО);
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеВопросаОЗагрузкеВремениВБитрикс(Результат, ДопПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		ЭкспортироватьВремяВБитриксНаСервере();
		ПересчитатьПодвал();
		Ошибки.Очистить();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеПодтвержденияПользователя(Результат, ДопПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		BitrixUser = ДопПараметры.ФИО;
		BitrixUserID = ДопПараметры.ИДПользователяБитрикс;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура СообщитьПользователю(
		Знач ТекстСообщенияПользователю,
		Знач КлючДанных,
		Знач Поле) Экспорт
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = ТекстСообщенияПользователю;
	Сообщение.Поле = Поле;
	Сообщение.КлючДанных = КлючДанных;
	Сообщение.Сообщить();
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьПодвал()
	
	ЗатраченныеЧасы 	 = 0;
	Минуты				 = 0;
	Секунды				 = 0;
	ИтогоЗатраченоСекунд = 0;
	
	Для Каждого СтрЗатраченноеВремя Из ЗатраченноеВремя Цикл
		
		СоответствуетОтобору = Элементы.ЗатраченноеВремя.ПроверитьСтроку(СтрЗатраченноеВремя.ПолучитьИдентификатор());
		Если НЕ СоответствуетОтобору Тогда
			Продолжить;
		КонецЕсли;
		
		ПотраченоСекунд = СтрЗатраченноеВремя.ДатаОкончания - СтрЗатраченноеВремя.ДатаНачала;
		ИтогоЗатраченоСекунд = ИтогоЗатраченоСекунд + ПотраченоСекунд;
		
	КонецЦикла;
	
	ЗатраченныеЧасы = Цел(ИтогоЗатраченоСекунд / 3600);
	Минуты = Цел((ИтогоЗатраченоСекунд - ЗатраченныеЧасы * 3600) / 60);
	Секунды = ИтогоЗатраченоСекунд - ЗатраченныеЧасы * 3600 - Минуты * 60;
	КоличествоНеВыгруженныхЗадач = ЗатраченноеВремя.НайтиСтроки(Новый Структура("УчтеноВБитрикс", Ложь)).Количество();
	
	Элементы.ЗатраченноеВремяНазваниеЗадачи.ТекстПодвала = СтрШаблон("Не выгружено: %1", КоличествоНеВыгруженныхЗадач);
	Элементы.ЗатраченноеВремяЗатраченоеВремя.ТекстПодвала = СтрШаблон("%1 ч. %2 м. %3 с.", ЗатраченныеЧасы, Минуты, Секунды);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВидомостьОшибок()
	
	КоличествоОшибок = Ошибки.Количество();
	
	Элементы.Ошибки.Видимость		   = КоличествоОшибок > 0;
	Элементы.ДекорацияОшибки.Видимость = КоличествоОшибок > 0;
	
	Если КоличествоОшибок > 0 Тогда
		СообщитьПользователю("Есть записи с ошибками. Посмотреть детали можно на странице ""Ошибки"".", Неопределено, Неопределено);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСтрокуНастроекЭлементов(СтрокаНастроек, КоллекцияЭлементовНастройки)
	
	Для Каждого ЭлементНастройки Из КоллекцияЭлементовНастройки Цикл
		
		Если ТипЗнч(ЭлементНастройки) = Тип("ГруппаФормы") Тогда
			СтрокаНастроек = ПолучитьСтрокуНастроекЭлементов(СтрокаНастроек, ЭлементНастройки.ПодчиненныеЭлементы);
		КонецЕсли;
		
		Если Не ЭлементНастройки.Вид = ВидПоляФормы.ПолеВвода И
			 Не ЭлементНастройки.Вид = ВидПоляФормы.ПолеФлажка Тогда	
			Продолжить;
		КонецЕсли;
			
		СтрокаНастроек = СтрШаблон("%1%2=%3%4", СтрокаНастроек, ЭлементНастройки.Имя, 
												ЭтаФорма[ЭлементНастройки.Имя], Символы.ПС);
		
	КонецЦикла;
	
	Возврат СтрокаНастроек;
	
КонецФункции

&НаКлиенте
Функция СформироватьСтрокуТекущихНастроек()
	
	СтрокаНастроек = "";
	
	ГруппаЭлементовНастроек = Элементы.Найти("ГруппаНастройки");
	Если ГруппаЭлементовНастроек = Неопределено Тогда
		Возврат СтрокаНастроек;
	КонецЕсли;
	
	СтрокаНастроек = ПолучитьСтрокуНастроекЭлементов(СтрокаНастроек, ГруппаЭлементовНастроек.ПодчиненныеЭлементы);
	СекцияНастроек = СтрШаблон("[%1]%2", Элементы.СтраницаНастройки.Заголовок, Символы.ПС);
	СтрокаНастроек = СтрШаблон("%1%2", СекцияНастроек, СтрокаНастроек);
	
	Возврат СтрокаНастроек;
	
КонецФункции

&НаКлиенте
Процедура ВыборКаталогаДляСохраненияЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ОчиститьСообщения();
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Каталог = Результат[0];
	СтрокаНастроек = СформироватьСтрокуТекущихНастроек();
	ФайлINI = Новый ТекстовыйДокумент;
	ФайлINI.УстановитьТекст(СтрокаНастроек);
	
	Попытка
		ПолныйПутьФайла = СтрШаблон("%1\ClockifyToBitrix24Settings.ini", Каталог);
		ФайлINI.Записать(ПолныйПутьФайла, КодировкаТекста.UTF8);
		СообщитьПользователю("Настройки сохранены", Неопределено, Неопределено);
	Исключение
		СообщитьПользователю(СтрШаблон("Не удалось сохранить настройки: %1", ОписаниеОшибки()), Неопределено, Неопределено);
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьЭлементНастройки(ИмяРеквизитаФормы, ЗначениеРеквизитаФормы)
	
	ЭтаФорма[ИмяРеквизитаФормы] = ЗначениеРеквизитаФормы;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборФайлаНастроекЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ОчиститьСообщения();
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПутьКФайлу = Результат[0];
	Файл = Новый ЧтениеТекста(ПутьКФайлу);
	СтрокаТекста = Файл.ПрочитатьСтроку();
	
	МассивОшибок = Новый Массив;
	Пока СтрокаТекста <> Неопределено Цикл
		
		СтрокаТекста = Файл.ПрочитатьСтроку();
		
		ЭлементЗначение = СтрРазделить(СтрокаТекста, "=", Ложь);
		
		ЕстьОшибкаВНастройке = ЭлементЗначение.Количество() <> 2;
		Если ЕстьОшибкаВНастройке Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			ЗаполнитьЭлементНастройки(ЭлементЗначение[0], ЭлементЗначение[1]);
		Исключение
			МассивОшибок.Добавить(ОписаниеОшибки());
		КонецПопытки;
		
	КонецЦикла;
	
	ТекстЗавершенияВосстановленияНастроек = "Настройки восстановлены";
	Если МассивОшибок.Количество() > 0 Тогда
		ТекстЗавершенияВосстановленияНастроек = СтрШаблон("%1:%2", "Есть ошибки при восстановлении настроек",
																			 СтрСоединить(МассивОшибок, ","));
	КонецЕсли;
	
	СообщитьПользователю(ТекстЗавершенияВосстановленияНастроек, Неопределено, Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьБитриксСписокЗадач()
	
	Элементы.ЗатраченноеВремя.ОтборСтрок = Неопределено;
	Элементы.БитриксСписокЗадач.СписокВыбора.Очистить();
	
	МассивДобавленнных = Новый Массив;
	Для каждого СтрокаТаблицы Из ЗатраченноеВремя Цикл
		
		Если МассивДобавленнных.Найти(СтрокаТаблицы.НомерЗадачи) = Неопределено Тогда
			МассивДобавленнных.Добавить(СтрокаТаблицы.НомерЗадачи);
			Задача = СтрокаТаблицы.НомерЗадачи + " " + СтрокаТаблицы.НазваниеЗадачи;
			Элементы.БитриксСписокЗадач.СписокВыбора.Добавить(Задача, Задача);
		КонецЕсли;
	КонецЦикла;
	
	Элементы.БитриксСписокЗадач.СписокВыбора.Вставить(0,"",СтрШаблон("Все задачи (%1)", МассивДобавленнных.Количество()));
	Элементы.БитриксСписокЗадач.СписокВыбора.СортироватьПоЗначению(НаправлениеСортировки.Возр);
	БитриксСписокЗадач = Элементы.БитриксСписокЗадач.СписокВыбора[0];
	
КонецПроцедуры

&НаКлиенте
Процедура ЗатраченноеВремяУстановитьОтборСтрок()
	
	СтруктураПоиска = Новый Структура();
	
	Если СтрНайти(БитриксСписокЗадач,"Все задачи") = 0 И БитриксСписокЗадач <> "" Тогда
		СтруктураПоиска.Вставить("НомерЗадачи", СтрРазделить(БитриксСписокЗадач, " ",Ложь)[0]);
	КонецЕсли;
	
	Если ФильтрПоНевыгруженнымВБитрикс = 1 Тогда
		СтруктураПоиска.Вставить("УчтеноВБитрикс", Ложь);
	КонецЕсли;
	
	Элементы.ЗатраченноеВремя.ОтборСтрок = Новый ФиксированнаяСтруктура(СтруктураПоиска);
	
КонецПроцедуры

#КонецОбласти