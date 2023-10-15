﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьКоличествоПолучаемыхЗаписей();
	
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПересчитатьПодвал();
	УстановитьВидомостьОшибок();
	
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
	ФильтрПоНевыгруженнымВБитриксПриИзменении(Элементы.ФильтрПоНевыгруженнымВБитрикс);
	
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	ПолучитьДанныеОЗатраченномВремени();
	
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
		ТекстВопроса = СтрШаблон("Вы хотите загрузить %1 записей в битрикс задачу №%2.%3Продолжить?",
				КоличествоЗаписейДляЗагрузки, СокрЛП(БитриксНомерЗадачи), Символы.ПС);
		
		Оповещение = Новый ОписаниеОповещения("ПослеВопросаОЗагрузкеВремениВБитрикс", ЭтотОбъект, Новый Структура());
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
	Иначе
		Если ЗатраченноеВремя.Количество() > 0 Тогда
			ТекстСообщения = "Все записи о времени уже выгружены в Битрикс24";
			СообщитьПользователю(ТекстСообщения, Неопределено, Неопределено);
		Иначе
			СообщитьПользователю("Нечего выгружать", Неопределено, Неопределено);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура БитриксНомерЗадачиПриИзменении(Элемент)
	
	ЭтаФорма.ТекущийЭлемент = Элементы.ПолучитьВремяClockify;
	
	ОчиститьЗатраченноеВремя();
	
КонецПроцедуры

&НаКлиенте
Процедура ФильтрПоНевыгруженнымВБитриксПриИзменении(Элемент)
	
	Если ФильтрПоНевыгруженнымВБитрикс = 0 Тогда
		Элементы.ЗатраченноеВремя.ОтборСтрок = Неопределено;
	Иначе
		Элементы.ЗатраченноеВремя.ОтборСтрок = Новый ФиксированнаяСтруктура("УчтеноВБитрикс", Ложь);
	КонецЕсли;
	
	ПересчитатьПодвал();
	
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

&НаКлиенте
Процедура ПолучитьВремяClockifyДоступность()
	
	Элементы.ПолучитьВремяClockify.Доступность = ЗначениеЗаполнено(ClockifyAPIkey) И ЗначениеЗаполнено(БитриксНомерЗадачи);
	
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
	
	НомерЗадачиБитрикс = СокрЛП(БитриксНомерЗадачи);
	Если ЗначениеЗаполнено(НомерЗадачиБитрикс) Тогда
		ЭтоЗаписьПоДругойЗадаче = СтрНайти(ОписаниеЗатраченногоВремени, НомерЗадачиБитрикс) = 0;
		Если ЭтоЗаписьПоДругойЗадаче Тогда
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
		
		Если ФильтрПоНевыгруженнымВБитрикс = 1 И СтрЗатраченноеВремя.УчтеноВБитрикс Тогда
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


#КонецОбласти