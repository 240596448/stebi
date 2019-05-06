#Использовать logos
#Использовать v8metadata-reader

Перем _Лог;

Перем _ПрименятьНастройки;
Перем _ФайлыОшибок;
Перем _ФайлНастроек;
Перем _КаталогИсходников;
Перем _УдалятьПоддержку;

Перем _ДанныеПоддержки;

#Область ПрограммныйИнтерфейс

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Аргумент("GENERIC_ISSUE_JSON", "" ,"Путь к файлам generic-issue.json, на основе которых будет создан файл настроек. Например ./edt-json.json,./acc-generic-issue.json")
	.ТСтрока()
	.ВОкружении("GENERIC_ISSUE_JSON");
	
	Команда.Опция("s settings", "" ,"Путь к файлу настроек. Например -s=./generic-issue-settings.json")
	.ТСтрока()
	.ВОкружении("GENERIC_ISSUE_SETTINGS_JSON");
	
	Команда.Опция("src", "" ,"Путь к каталогу с исходниками. Например -src=./src")
	.ТСтрока()
	.ВОкружении("SRC");
	
	Команда.Опция("r remove_support", "" ,"Удаляет из отчетов файлы на поддержке. Например -r=0
	|		0 - удалить файлы на замке,
	|		1 - удалить файлы на замке и на поддержке
	|		2 - удалить файлы на замке, на поддержке и снятые с поддержки")
	.ТЧисло()
	.ВОкружении("GENERIC_ISSUE_REMOVE_SUPPORT");
	
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	ИнициализацияПараметров(Команда);
	
	Если _ПрименятьНастройки Тогда
		
		_лог.Информация( "Начало чтения файла настроек <%1>", _ФайлНастроек);
		таблицаНастроек = ОбщегоНазначения.ПолучитьТаблицуНастроек( _ФайлНастроек, _Лог );
		_лог.Информация( "Из файла настроек прочитано: " + таблицаНастроек.Количество() );
		
	Иначе
		
		таблицаНастроек = Новый ТаблицаЗначений;
		
	КонецЕсли;
	
	Для каждого цФайл Из _файлыОшибок Цикл
		
		ошибкиФайла = ОбщегоНазначения.ПрочитатьJSONФайл( цФайл, _Лог );
		
		началоЗамера = ТекущаяУниверсальнаяДатаВМиллисекундах();
		
		Если Не ТипЗнч( ошибкиФайла ) = Тип("Структура") Тогда
			
			_Лог.Ошибка( "Не поддерживаемая структура файла: " + цФайл );			
			Продолжить;
			
		КонецЕсли;
		
		Если Не ошибкиФайла.Свойство("issues") Тогда
			
			_Лог.Ошибка( "Не поддерживаемая структура файла: " + цФайл );			
			Продолжить;
			
		КонецЕсли;
		
		Если Не ТипЗнч( ошибкиФайла.issues ) = Тип("Массив") Тогда
			
			_Лог.Ошибка( "Не поддерживаемая структура файла: " + цФайл );			
			Продолжить;
			
		КонецЕсли;
		
		файлИзменен = Ложь;
		
		всегоОшибок = ошибкиФайла.issues.Количество();
		
		Для ц = 1 По всегоОшибок Цикл
			
			цОшибка = ошибкиФайла.issues[всегоОшибок-ц];
			
			Если ФайлНаПоддержке( цОшибка ) Тогда
				
				ошибкиФайла.issues.Удалить(всегоОшибок-ц);
				файлИзменен = Истина;
				Продолжить;

			КонецЕсли;
				
			Если ПрименитьНастройки( цОшибка, таблицаНастроек ) Тогда
				
				файлИзменен = Истина;
				
			КонецЕсли;

			Если цОшибка.severity = "SKIP" Тогда

				ошибкиФайла.issues.Удалить(всегоОшибок-ц);
				файлИзменен = Истина;
				Продолжить;

			КонецЕсли;
			
		КонецЦикла;
		
		_Лог.Информация( "Файл <%1> обработан за %2мс", цФайл, ТекущаяУниверсальнаяДатаВМиллисекундах() - началоЗамера );
		
		Если файлИзменен Тогда
			
			_лог.Информация( "Запись в файл: " +  цФайл);
			ОбщегоНазначения.ЗаписатьJSONВФайл(ошибкиФайла, цФайл, _Лог);
			
		Иначе
			
			_лог.Информация( "Изменения в файле не требуются: " +  цФайл);
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ИнициализацияПараметров(Знач Команда)
	
	_Лог = Логирование.ПолучитьЛог(ИмяЛога());

	файлыОшибок = Команда.ЗначениеАргумента("GENERIC_ISSUE_JSON");
	_лог.Отладка( "GENERIC_ISSUE_JSON = " + файлыОшибок );

	путьКФайлуНастроек = Команда.ЗначениеОпции("settings");
	_лог.Отладка( "settings = " + путьКФайлуНастроек );

	путьККаталогуИсходников = Команда.ЗначениеОпции("src");
	_лог.Отладка( "src = " + путьККаталогуИсходников );

	_УдалятьПоддержку = Команда.ЗначениеОпции("remove_support");
	_лог.Отладка( "remove_support = " + _УдалятьПоддержку );
	
	Если ЗначениеЗаполнено( путьКФайлуНастроек ) Тогда
		
		_ФайлНастроек = ОбщегоНазначения.АбсолютныйПуть( путьКФайлуНастроек );
		_лог.Отладка( "Файл настроек = " + _ФайлНастроек );
		
		_ПрименятьНастройки = ОбщегоНазначения.ФайлСуществует( _ФайлНастроек );
		
	Иначе
		
		_ПрименятьНастройки = Ложь;
		
	КонецЕсли;
	
	_файлыОшибок = Новый Массив;
	
	Для каждого цПутьКФайлу Из СтрРазделить( файлыОшибок, ",") Цикл
		
		Если ОбщегоНазначения.ФайлСуществует(цПутьКФайлу) Тогда
			
			файлСОшибками = ОбщегоНазначения.АбсолютныйПуть( цПутьКФайлу );
			
			_файлыОшибок.Добавить(файлСОшибками);
			
			_лог.Отладка( "Добавлен файл generic-issue = " + файлСОшибками );
			
		КонецЕсли;
		
	КонецЦикла;
	
	_КаталогИсходников = ОбщегоНазначения.АбсолютныйПуть(путьККаталогуИсходников);
	каталогИсходников = Новый Файл(_КаталогИсходников);
	_лог.Отладка( "Каталог исходников = " + _КаталогИсходников );
	
	Если Не каталогИсходников.Существует()
		Или Не каталогИсходников.ЭтоКаталог() Тогда
		
		_лог.Ошибка( СтрШаблон("Каталог исходников <%1> не существует. Файлы на поддержке удалены не будут", путьККаталогуИсходников) );
		_УдалятьПоддержку = Неопределено;
		
	КонецЕсли;
	
	Если Не _ПрименятьНастройки
		И _УдалятьПоддержку = Неопределено Тогда
		_Лог.Ошибка( "Должен быть указан файл настроек или уровень удаления поддержки." );
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	Если Не _УдалятьПоддержку = Неопределено Тогда

		_ДанныеПоддержки = Новый Поддержка(_КаталогИсходников);

	КонецЕсли;

КонецПроцедуры

Функция ПрименитьНастройки( пОшибка, таблицаНастроек )
	
	естьИзменения = Ложь;
	
	ruleId = пОшибка.ruleId;
	message = пОшибка.primaryLocation.message;
	filePath = ОбщегоНазначения.АбсолютныйПуть( пОшибка.primaryLocation.filePath );
	
	заголовокЛога = СтрШаблон( "ruleId: <%1>, message: <%2>, filePath: <%3>. Установлено ", 
	ruleId,
	message,
	filePath);
	
	Для каждого цСтрока Из таблицаНастроек Цикл
		
		Если НастройкаПрименима( ruleId, цСтрока.ruleId )
			И НастройкаПрименима( message, цСтрока.message )
			И НастройкаПрименима( filePath, цСтрока.filePath ) Тогда
			
			Если ТипЗнч( цСтрока.effortMinutes ) = Тип("Число")
				И Не цСтрока.effortMinutes = пОшибка.effortMinutes Тогда
				
				_лог.Отладка( заголовокЛога + "effortMinutes: " + цСтрока.effortMinutes );
				
				пОшибка.effortMinutes = цСтрока.effortMinutes;
				естьИзменения = Истина;
				
			КонецЕсли;
			
			Если Не цСтрока.severity = пОшибка.severity 
				И (цСтрока.severity = "BLOCKER"
				ИЛИ цСтрока.severity = "CRITICAL"
				ИЛИ цСтрока.severity = "MAJOR"
				ИЛИ цСтрока.severity = "MINOR"
				ИЛИ цСтрока.severity = "INFO"
				ИЛИ цСтрока.severity = "SKIP") Тогда
				
				_лог.Отладка( заголовокЛога + "severity: " + цСтрока.severity );
				
				пОшибка.severity = цСтрока.severity;
				естьИзменения = Истина;
				
			КонецЕсли;
			
			Если Не цСтрока.type = пОшибка.type
				И (цСтрока.type = "BUG"
				ИЛИ цСтрока.type = "VULNERABILITY"
				ИЛИ цСтрока.type = "CODE_SMELL") Тогда
				
				_лог.Отладка( заголовокЛога + "type: " + цСтрока.type );
				
				пОшибка.type = цСтрока.type;
				естьИзменения = Истина;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат естьИзменения;
	
КонецФункции

Функция НастройкаПрименима( пСтрока, пШаблон)
	
	Если пСтрока = пШаблон Тогда
		Возврат Истина;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено( пШаблон ) Тогда
		Возврат Истина;
	КонецЕсли;
	
	Попытка
		
		регВыражение = Новый РегулярноеВыражение( пШаблон );
		Возврат регВыражение.Совпадает( пСтрока );
		
	Исключение
		
		_Лог.Ошибка("Ошибка сравнения ""%1"" с рег. выражением ""%2""", пСтрока, пШаблон);
		_Лог.Ошибка(ОписаниеОшибки());
		Возврат Ложь;
		
	КонецПопытки;
	
КонецФункции

Функция ФайлНаПоддержке(Знач пОшибка)
	
	Если _УдалятьПоддержку = Неопределено Тогда

		Возврат Ложь;

	КонецЕсли;

	путьКФайлу = пОшибка.primaryLocation.filePath;
	путьКФайлу = ОбщегоНазначения.АбсолютныйПуть(путьКФайлу);

	текУровень = _ДанныеПоддержки.Уровень( путьКФайлу );

	Возврат текУровень <= _УдалятьПоддержку;

КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ИмяЛога() Экспорт
	Возврат "oscript.app." + ОПриложении.Имя();
КонецФункции

#КонецОбласти
