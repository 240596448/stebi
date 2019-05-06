
Функция ФайлСуществует(Знач пИмяФайла) Экспорт
	
	файл = Новый Файл( УбратьКавычки( пИмяФайла ) );
	
	Возврат файл.Существует()
	И Не файл.ЭтоКаталог();
	
КонецФункции

Функция АбсолютныйПуть(Знач пИмяФайла) Экспорт
	
	файл = Новый Файл( УбратьКавычки( пИмяФайла ) );
	
	Возврат СтрЗаменить( файл.ПолноеИмя, "\", "/" );
	
КонецФункции

Функция УбратьКавычки(Знач пСтрока)
	
	строкаБезКавычек = пСтрока;

	Если СтрНачинаетсяС(строкаБезКавычек, """") Тогда
		СтрокаБезКавычек = Сред(СтрокаБезКавычек, 2);
	КонецЕсли;

	Если СтрЗаканчиваетсяНа(строкаБезКавычек, """") Тогда
		СтрокаБезКавычек = Лев(СтрокаБезКавычек, СтрДлина(СтрокаБезКавычек) - 1);
	КонецЕсли;

	СтрокаБезКавычек = СтрЗаменить(СтрокаБезКавычек, """""", """");

	Возврат строкаБезКавычек;

КонецФункции

Функция ПолучитьТаблицуНастроек( Знач пФайлНастроек, Знач Лог ) Экспорт
	
	таблицаНастроек = Новый ТаблицаЗначений;
	таблицаНастроек.Колонки.Добавить("ruleId");
	таблицаНастроек.Колонки.Добавить("message");
	таблицаНастроек.Колонки.Добавить("filePath");
	таблицаНастроек.Колонки.Добавить("severity");
	таблицаНастроек.Колонки.Добавить("type");
	таблицаНастроек.Колонки.Добавить("effortMinutes");
	
	Если ФайлСуществует( пФайлНастроек ) Тогда
		
		настройки = ПрочитатьJSONФайл( пФайлНастроек, Лог );
		
		Для каждого цСтрокаНастройки Из настройки Цикл
			
			ЗаполнитьЗначенияСвойств( таблицаНастроек.Добавить(), цСтрокаНастройки );
			
		КонецЦикла;

	КонецЕсли;
	
	Возврат таблицаНастроек;

КонецФункции

Функция ПолучитьТекстИзФайла( Знач пИмяФайла )
	
	прочитанныйТекст = "";
	чтениеТекста = Новый ЧтениеТекста(пИмяФайла, КодировкаТекста.UTF8);
	прочитанныйТекст = чтениеТекста.Прочитать();
	чтениеТекста.Закрыть();
	возврат прочитанныйТекст;

КонецФункции

Функция ПрочитатьJSONФайл( Знач пИмяФайла, Знач Лог ) Экспорт
	
	текДата = ТекущаяУниверсальнаяДатаВМиллисекундах();

	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.ОткрытьФайл( пИмяФайла, "UTF-8" );
	
	прочитанныйТекст = ПрочитатьJSON(ЧтениеJSON);

	Лог.Информация( "JSON прочитан из <%1> за %2мс", пИмяФайла, ТекущаяУниверсальнаяДатаВМиллисекундах() - текДата );

	Возврат прочитанныйТекст;
	
КонецФункции

Процедура ЗаписатьJSONВФайл( Знач пЗначение, Знач пИмяФайла, Знач Лог ) Экспорт
	
	текДата = ТекущаяУниверсальнаяДатаВМиллисекундах();

	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.ОткрытьФайл( пИмяФайла, "UTF-8");
	ЗаписатьJSON( ЗаписьJSON, пЗначение );
	ЗаписьJSON.Закрыть();

	Лог.Информация( "JSON записан в <%1> за %2мс", пИмяФайла, ТекущаяУниверсальнаяДатаВМиллисекундах() - текДата );

КонецПроцедуры

