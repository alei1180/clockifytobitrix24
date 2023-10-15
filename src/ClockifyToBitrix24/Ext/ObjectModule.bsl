﻿
#Область ПрограммныйИнтерфейс

Функция СведенияОВнешнейОбработке() Экспорт 
	
	ПараметрыРегистрации = Неопределено;
	
	Если ЕстьОбщийМодуль("ДополнительныеОтчетыИОбработки") Тогда
		ПараметрыРегистрации = Вычислить("ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке()");
		ПараметрыРегистрации.Вид = Вычислить("ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка()");
		ПараметрыРегистрации.Версия = ПолучитьВерсиюПроекта();
		ПараметрыРегистрации.Информация = СтрШаблон("Экспорт времени из Clockify в Bitrix24.%1Автор: Александр Осадчий (https://github.com/alei1180)", Символы.ПС+Символы.ПС);
		ПараметрыРегистрации.БезопасныйРежим = Ложь; 
	КонецЕсли;
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

#Область Clockify_API

Функция Clockify_ДанныеПользователя(ClockifyAPIkey) Экспорт
	
	АдресСервера = "api.clockify.me";
	Метод = "/api/v1/user";
	
	Возврат Clockify_ОтправитьGETЗапрос(АдресСервера, ClockifyAPIkey, Метод);
	
КонецФункции

Функция Clockify_ДанныеПоЗатраченномуВремени(ClockifyAPIkey, ClockifyactiveWorkspace, ClockifyUserID, ClockifyPageSize) Экспорт
	
	АдресСервера = "api.clockify.me";
	Метод = СтрШаблон("/api/v1/workspaces/%1/user/%2/time-entries/", ClockifyactiveWorkspace, ClockifyUserID);
	
	Возврат Clockify_ОтправитьGETЗапрос(АдресСервера, ClockifyAPIkey, Метод, ClockifyPageSize);
	
КонецФункции

#КонецОбласти

#Область Bitrix_API

Функция Bitrix_Пользователь(URL, ВебХук, ИДПользователя) Экспорт
		
	Метод = "user.get.json?";
	
	СтрокаЗапроса = СтрШаблон("%1%2", ВебХук, Метод); 
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ID", Формат(ИДПользователя, "ЧГ="));
	СтруктураПараметров.Вставить("ADMIN_MODE", Истина);
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON,СтруктураПараметров);
	СтрокаJSON = ЗаписьJSON.Закрыть();
	
	Соединение = Новый HTTPСоединение(СокрЛП(URL),443,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	
	ЗаголовокHTTP = Новый Соответствие();
	ЗаголовокHTTP.Вставить("Content-Type", "application/json; charset=utf-8");	
	Запрос = Новый HTTPЗапрос(СтрокаЗапроса,ЗаголовокHTTP);
	Запрос.УстановитьТелоИзСтроки(СтрокаJSON);
	
	Результат = Соединение.ОтправитьДляОбработки(Запрос);
	
	СтрокаОтвета = Результат.ПолучитьТелоКакСтроку();
	
	СтрокаJSONПервыеЗаписи = СтрокаОтвета;
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(СтрокаJSONПервыеЗаписи);
	СтруктураОтвета = ПрочитатьJSON(ЧтениеJSON);
	
	Если Результат.КодСостояния <> 200 Тогда 
		Сообщение = СтрШаблон("Код ошибки: %1: %2", Результат.КодСостояния, СтруктураОтвета.error_description);
		Сообщить(Сообщение);
		Возврат Неопределено;
	КонецЕсли;
	
	Если НЕ СтруктураОтвета.Свойство("result") Тогда 	
		Возврат Неопределено;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтруктураОтвета.result) Тогда		
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат СтруктураОтвета.result[0];;
	
КонецФункции

Процедура Bitrix_Задача_ПолучитьЗатраченноеВремя(URL, ВебХук, НомерЗадачи, ИДПользователя, ТолькоДанныеПоТекущемуПользователю = Ложь, ЗатраченноеВремя) Экспорт
	
	Метод	= "task.elapseditem.getlist.json?";
	
	СтрокаЗапроса = СтрШаблон("%1%2", ВебХук, Метод);
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("TASKID", НомерЗадачи);
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON,СтруктураПараметров);
	СтрокаJSON = ЗаписьJSON.Закрыть();
	
	Соединение = Новый HTTPСоединение(СокрЛП(URL),443,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	
	ЗаголовокHTTP = Новый Соответствие();
	ЗаголовокHTTP.Вставить("Content-Type", "application/json; charset=utf-8");	
	Запрос = Новый HTTPЗапрос(СтрокаЗапроса,ЗаголовокHTTP);
	Запрос.УстановитьТелоИзСтроки(СтрокаJSON);
	
	Результат = Соединение.ОтправитьДляОбработки(Запрос);
		
	СтрокаОтвета = Результат.ПолучитьТелоКакСтроку();
	
	СтрокаJSONПервыеЗаписи = СтрокаОтвета;
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(СтрокаJSONПервыеЗаписи);
	СтруктураОтвета = ПрочитатьJSON(ЧтениеJSON);
	
	Если Результат.КодСостояния <> 200 Тогда 
		
		Если Результат.КодСостояния = 400 И СтрНайти(СтруктураОтвета.error_description, "Task not found") > 0 Тогда
			Сообщение = СтрШаблон("Код ошибки: %1: Задача %2 не найдена или недостаточно прав на действия с ней.", Результат.КодСостояния, НомерЗадачи);
			Сообщить(Сообщение);	
		Иначе
			Сообщение = СтрШаблон("Код ошибки: %1: %2", Результат.КодСостояния, СтруктураОтвета.error_description);
			Сообщить(Сообщение);	
		КонецЕсли; 
		
		Возврат;
		
	КонецЕсли;
	
	Если НЕ СтруктураОтвета.Свойство("result") Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗатраченноеВремя.Колонки.Количество() = 0 Тогда
		ЗатраченноеВремя.Колонки.Добавить("Запись_ID"); 
		ЗатраченноеВремя.Колонки.Добавить("Задача_ID");
		ЗатраченноеВремя.Колонки.Добавить("ПользовательБитрикс_ID");
		ЗатраченноеВремя.Колонки.Добавить("ДатаСоздания");
		ЗатраченноеВремя.Колонки.Добавить("ДатаНачало");
		ЗатраченноеВремя.Колонки.Добавить("ДатаОкончание");
		ЗатраченноеВремя.Колонки.Добавить("Секунды");
		ЗатраченноеВремя.Колонки.Добавить("Минуты");
		ЗатраченноеВремя.Колонки.Добавить("Комментарий");
	КонецЕсли;
		
	МассивДанныхПоЗатраченномуВремени = СтруктураОтвета.result;
	Для каждого ДанныеОЗатраченномВремени Из МассивДанныхПоЗатраченномуВремени Цикл 
		
		Если ТолькоДанныеПоТекущемуПользователю Тогда
			Если ДанныеОЗатраченномВремени.USER_ID <> Формат(ИДПользователя, "ЧГ=") Тогда	
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		СтрЗатраченноеВремя = ЗатраченноеВремя.Добавить();
		
		СтрЗатраченноеВремя.Запись_ID				= ДанныеОЗатраченномВремени.ID;
		СтрЗатраченноеВремя.Задача_ID				= ДанныеОЗатраченномВремени.TASK_ID;
		СтрЗатраченноеВремя.ПользовательБитрикс_ID	= ДанныеОЗатраченномВремени.USER_ID;
		СтрЗатраченноеВремя.ДатаСоздания			= ПрочитатьДатуJSON(ДанныеОЗатраченномВремени.CREATED_DATE, ФорматДатыJSON.ISO);;
		СтрЗатраченноеВремя.ДатаНачало				= ПрочитатьДатуJSON(ДанныеОЗатраченномВремени.DATE_START, ФорматДатыJSON.ISO);
		СтрЗатраченноеВремя.ДатаОкончание			= ПрочитатьДатуJSON(ДанныеОЗатраченномВремени.DATE_STOP, ФорматДатыJSON.ISO);;
		СтрЗатраченноеВремя.Секунды					= Число(ДанныеОЗатраченномВремени.SECONDS);
		СтрЗатраченноеВремя.Минуты					= Число(ДанныеОЗатраченномВремени.MINUTES);
		СтрЗатраченноеВремя.Комментарий				= ДанныеОЗатраченномВремени.COMMENT_TEXT;
		
	КонецЦикла;
	
КонецПроцедуры

Функция Bitrix_Задача_ДобавитьЗатраченноеВремя(URL, ВебХук, НомерЗадачи, ДеталиЗаписиОЗатраченномВремени) Экспорт
	
	Метод	= "task.elapseditem.add.json?";
	
	СтрокаЗапроса = СтрШаблон("%1%2", ВебХук, Метод); 
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("TASKID",		НомерЗадачи);
	СтруктураПараметров.Вставить("ARFIELDS",	ДеталиЗаписиОЗатраченномВремени);
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON,СтруктураПараметров);
	СтрокаJSON = ЗаписьJSON.Закрыть();
	
	Соединение = Новый HTTPСоединение(СокрЛП(URL),443,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	
	ЗаголовокHTTP = Новый Соответствие();
	ЗаголовокHTTP.Вставить("Content-Type", "application/json; charset=utf-8");	
	Запрос = Новый HTTPЗапрос(СтрокаЗапроса,ЗаголовокHTTP);
	Запрос.УстановитьТелоИзСтроки(СтрокаJSON);
	
	Результат = Соединение.ОтправитьДляОбработки(Запрос);
		
	СтрокаОтвета = Результат.ПолучитьТелоКакСтроку();
	
	СтрокаJSONПервыеЗаписи = СтрокаОтвета;
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(СтрокаJSONПервыеЗаписи);
	Ответ = ПрочитатьJSON(ЧтениеJSON, Истина); 

	АйдиДобавленнойЗаписиОВремени = Ответ.Получить("result");
	
	Если НЕ ЗначениеЗаполнено(АйдиДобавленнойЗаписиОВремени) Тогда
		АйдиДобавленнойЗаписиОВремени = 0;
	КонецЕсли;
	
	Возврат АйдиДобавленнойЗаписиОВремени;
	
КонецФункции

// Функция - возвращает таблицу значений с информацией по задачам битрикс
//
// Параметры:
//  URL						 - Строка - адрес портала Битрикс
//  Вебхук					 - Строка - вебхук битрикс, с правами на выполнение метода
//  НомераЗадач				 - Массив - массив с номерами задач, номер задачи указывается строкой
//  ПолучитьНазваниеЗадачи	 - Булево - признак получения названия задачи
//  ПолучитьОписаниеЗадачи	 - Булево - признак получения описания задачи
//  ПолучитьСтатусЗадачи	 - Булево - признак получения статуса задачи
//  ПолучитьПостановщика	 - Булево - признак получения постановщика задачи
//  ПолучитьОтветственного	 - Булево - признак получения ответственного по задаче
//  ПолучитьСоисполнителей	 - Булево - признак получения соисполнителей задачи
//  ПолучитьНаблюдателей	 - Булево - признак получения наблюдателей задачи
// 
// Возвращаемое значение:
// ТаблицаЗначений - ТаблицаЗначений - ТЗ с информацией по задачам, колонки имеют тип строка: НомерЗадачи, НазваниеЗадачи, ОписаниеЗадачи, Постановщик, Ответственный, Соисполнители, Наблюдатели
//
Функция Bitrix_Задача_ПолучитьИнформацию(URL,
										 Вебхук,
										 НомераЗадач,
										 ПолучитьНазваниеЗадачи	= Истина,
										 ПолучитьОписаниеЗадачи	= Ложь,
										 ПолучитьСтатусЗадачи	= Ложь,
										 ПолучитьПостановщика	= Ложь,
										 ПолучитьОтветственного	= Ложь,
										 ПолучитьСоисполнителей	= Ложь,
										 ПолучитьНаблюдателей	= Ложь) Экспорт
	
	Если НЕ ТипЗнч(НомераЗадач) = Тип("Массив") Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если НомераЗадач.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТЗ = Новый ТаблицаЗначений;
	
	ТЗ.Колонки.Добавить("НомерЗадачи"); 
	Если ПолучитьНазваниеЗадачи Тогда
		ТЗ.Колонки.Добавить("НазваниеЗадачи");
	КонецЕсли;
	Если ПолучитьОписаниеЗадачи Тогда
		ТЗ.Колонки.Добавить("ОписаниеЗадачи");
	КонецЕсли;
	Если ПолучитьПостановщика Тогда
		ТЗ.Колонки.Добавить("Постановщик");
	КонецЕсли;
	Если ПолучитьОтветственного Тогда
		ТЗ.Колонки.Добавить("Ответственный");
	КонецЕсли;
	Если ПолучитьСоисполнителей Тогда
		ТЗ.Колонки.Добавить("Соисполнители");
	КонецЕсли;
	Если ПолучитьНаблюдателей Тогда 
		ТЗ.Колонки.Добавить("Наблюдатели");
	КонецЕсли;
	
	МассивПолучаемыхПолей = Новый Массив;
	
	Если ПолучитьНазваниеЗадачи Тогда
		МассивПолучаемыхПолей.Добавить("TITLE");
	КонецЕсли;
	Если ПолучитьОписаниеЗадачи Тогда
		МассивПолучаемыхПолей.Добавить("DESCRIPTION");
	КонецЕсли;
	Если ПолучитьСтатусЗадачи Тогда
		МассивПолучаемыхПолей.Добавить("STATUS");
	КонецЕсли;
	Если ПолучитьПостановщика Тогда
		МассивПолучаемыхПолей.Добавить("CREATED_BY");
	КонецЕсли;
	Если ПолучитьОтветственного Тогда
		МассивПолучаемыхПолей.Добавить("RESPONSIBLE_ID");
	КонецЕсли;	
	Если ПолучитьСоисполнителей Тогда
		МассивПолучаемыхПолей.Добавить("ACCOMPLICES");
	КонецЕсли;	
	Если ПолучитьНаблюдателей Тогда
		МассивПолучаемыхПолей.Добавить("AUDITORS");
	КонецЕсли;
	
	СтрПолучаемыеПоля = СтрСоединить(МассивПолучаемыхПолей, "&select[]=");
	СтрНомераЗадач = СтрСоединить(НомераЗадач, "&filter[ID][]=");
	
	Метод	= "tasks.task.list.json?";
	
	НачальнаяПозиция = 0;
	ВсегоПозиций = 1;
	
	Пока НачальнаяПозиция < ВсегоПозиций Цикл
		
		СтартоваяПозиция = ?(НачальнаяПозиция = 0, "", СтрШаблон("&start=%1", НачальнаяПозиция));
		
		СтрокаЗапроса = СтрШаблон("%1%2filter[ID][]=%3&select[]=%4%5", ВебХук, Метод, СтрНомераЗадач, СтрПолучаемыеПоля, СтартоваяПозиция);
		
		Запрос = Новый HTTPЗапрос(СтрокаЗапроса);
		Соединение = Новый HTTPСоединение(СокрЛП(URL),443,,,,,Новый ЗащищенноеСоединениеOpenSSL());
		Результат = Соединение.Получить(Запрос);
		
		СтрокаОтвета = Результат.ПолучитьТелоКакСтроку();
		
		СтрокаJSONПервыеЗаписи = СтрокаОтвета;
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(СтрокаJSONПервыеЗаписи);
		ОтветСоответствие = ПрочитатьJSON(ЧтениеJSON, Истина);
		
		ВсегоПозиций = ОтветСоответствие.Получить("total");
		
		МассивПолученныхЗадачБитрикса = ОтветСоответствие.Получить("result").Получить("tasks");
		
		Если НЕ ЗначениеЗаполнено(МассивПолученныхЗадачБитрикса) Тогда
			Возврат Неопределено;
		КонецЕсли;
		
		Для Каждого ЗадачаБитрикс Из МассивПолученныхЗадачБитрикса Цикл
			
			СтрТЗ = ТЗ.Добавить();
			
			СтрТЗ.НомерЗадачи		= ЗадачаБитрикс.Получить("id");
			Если ПолучитьНазваниеЗадачи Тогда
				СтрТЗ.НазваниеЗадачи	= ЗадачаБитрикс.Получить("title");
			КонецЕсли;
			Если ПолучитьОписаниеЗадачи Тогда
				СтрТЗ.ОписаниеЗадачи	= ЗадачаБитрикс.Получить("description");
			КонецЕсли;
			Если ПолучитьПостановщика Тогда
				СтрТЗ.Постановщик		= ЗадачаБитрикс.Получить("creator").Получить("name");
			КонецЕсли;
			Если ПолучитьОтветственного Тогда
				СтрТЗ.Ответственный		= ЗадачаБитрикс.Получить("responsible").Получить("name");
			КонецЕсли;
			Если ПолучитьСоисполнителей Тогда
				МассивИнформацииСоисполнители = ЗадачаБитрикс.Получить("accomplicesData");
				МассивФИОИсполнители = Новый Массив;
				Для Каждого ИнфоОСоисполнителе Из МассивИнформацииСоисполнители Цикл
					МассивФИОИсполнители.Добавить(ИнфоОСоисполнителе.Значение.Получить("name"));
				КонецЦикла;
				СтрТЗ.Соисполнители		= СтрСоединить(МассивФИОИсполнители, ", ");
			КонецЕсли;
			Если ПолучитьНаблюдателей Тогда 
				МассивИнформацииНаблюдатели = ЗадачаБитрикс.Получить("auditorsData");
				МассивФИОНаблюдатели = Новый Массив;
				Для Каждого ИнфоОНаблюдателе Из МассивИнформацииНаблюдатели Цикл
					МассивФИОНаблюдатели.Добавить(ИнфоОНаблюдателе.Значение.Получить("name"));
				КонецЦикла;
				СтрТЗ.Наблюдатели		= СтрСоединить(МассивФИОНаблюдатели, ", ");
			КонецЕсли;
			
		КонецЦикла;
		
		НачальнаяПозиция = НачальнаяПозиция + МассивПолученныхЗадачБитрикса.Количество();
		
	КонецЦикла;
	
	ТЗ.Индексы.Добавить("НомерЗадачи");
	
	Возврат ТЗ;
	
КонецФункции

#КонецОбласти

#Область GitHub_API

Функция GitHub_ПолучитьНомерПоследнейВерсии() Экспорт
	
	НомерПоследнейВерсии = "";
	
	Соединение = Новый HTTPСоединение("github.com",443,,,,,Новый ЗащищенноеСоединениеOpenSSL());	
	Запрос = Новый HTTPЗапрос("/alei1180/clockifytobitrix24/releases/latest"); 
	Ответ = Соединение.Получить(Запрос);
	
	Если Ответ.КодСостояния = 302 Тогда //переадресация
		
		АдресПоследнейВерсии = Ответ.Заголовки.Получить("Location");
		НомерПоследнейВерсии = Прав(АдресПоследнейВерсии, 5);
		
	КонецЕсли;
	
	Возврат НомерПоследнейВерсии;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьВерсиюПроекта() Экспорт
	
	Возврат "1.0.4";
	
КонецФункции

Функция ЕстьОбщийМодуль(НазваниеМодуля)
	
	Возврат Метаданные.ОбщиеМодули.Найти(НазваниеМодуля) <> Неопределено;
	
КонецФункции

Функция Clockify_ОтправитьGETЗапрос(АдресСервера, КлючАпи, Метод, ClockifyPageSize = 0)
	
	Заголовки = Новый Соответствие();
	Заголовки.Вставить("content-type", "application/json");
	Заголовки.Вставить("X-Api-Key", КлючАпи);
	
	Если ЗначениеЗаполнено(ClockifyPageSize) Тогда
		Параметры = СтрШаблон("?page-size=%1", Формат(ClockifyPageSize, "ЧГ="));
	Иначе
		Параметры = "";
	КонецЕсли;
	
	HTTPСоединение = Новый HTTPСоединение(АдресСервера,443,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	HTTPЗапрос = Новый HTTPЗапрос(Метод + Параметры, Заголовки);
	HTTPОтвет = HTTPСоединение.Получить(HTTPЗапрос);
	
	КодСостояния = HTTPОтвет.КодСостояния;
	Если КодСостояния <> 200 Тогда 
		СтрокаОтвета = HTTPОтвет.ПолучитьТелоКакСтроку();
		СтрокаJSON = СтрокаОтвета;
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(СтрокаJSON);
		
		HTTPОтвет = ПрочитатьJSON(ЧтениеJSON);
		
		Если HTTPОтвет.Свойство("message") Тогда
			Сообщение = HTTPОтвет.message;
		ИначеЕсли HTTPОтвет.Свойство("error") Тогда
			Сообщение = HTTPОтвет.error;
		КонецЕсли;
		
		СообщениеОбОшибке = СтрШаблон("Код ошибки: %1, Ошибка: %2", Формат(КодСостояния, "ЧГ="), Сообщение);
		Сообщить(СообщениеОбОшибке);
		Возврат Новый Структура;
	КонецЕсли;
	
	СтрокаОтвета = HTTPОтвет.ПолучитьТелоКакСтроку();
	СтрокаJSON = СтрокаОтвета;
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(СтрокаJSON);
	
	Возврат ПрочитатьJSON(ЧтениеJSON);
	
КонецФункции

Процедура СообщитьПользователю(
		Знач ТекстСообщенияПользователю,
		Знач КлючДанных,
		Знач Поле,
		Знач ПутьКДанным = "",
		Отказ = Ложь,
		ЭтоОбъект = Ложь) Экспорт
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = ТекстСообщенияПользователю;
	Сообщение.Поле = Поле;
	
	Если ЭтоОбъект Тогда
		Сообщение.УстановитьДанные(КлючДанных);
	Иначе
		Сообщение.КлючДанных = КлючДанных;
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(ПутьКДанным) Тогда
		Сообщение.ПутьКДанным = ПутьКДанным;
	КонецЕсли;
	
	Сообщение.Сообщить();
	
	Отказ = Истина;
	
КонецПроцедуры

#КонецОбласти
