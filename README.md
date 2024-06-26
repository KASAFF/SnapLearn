# SnapLearn

SnapLearn - это приложение для изучения слов и их значений. Оно позволяет пользователям добавлять новые слова, переводить их и сохранять для дальнейшего изучения.

## Описание проекта

Приложение SnapLearn позволяет пользователям:
- Вводить новые слова для поиска их определений и переводов.
- Сканировать текст слов с помощью камеры.
- Просматривать подробные значения слов, включая примеры и синонимы.
- Сохранять слова для дальнейшего изучения.
- Изучать слова с помощью карточек.

Используемые сервисы:
- DeepL для переводов
- Dictionaryapi для значений
- Unsplash для фотографий

Используемые фреймворки:
- SwiftUI
- SwiftData
- Kingfisher

## Выполненные задачи

### 1. Создание интерактивных UI компонентов с использованием SwiftUI

#### Переиспользуемый компонент `CardStackView`

**Описание:** `CardStackView` - это компонент, который используется для отображения и переворачивания карточек со словами. Он позволяет пользователям свайпать карточки влево или вправо для пометки слов как "нужно повторить" или "выучено". Карточки могут быть перевернуты для отображения их значений и примеров использования.

![CardStackView](https://github.com/KASAFF/SnapLearn/assets/91468100/94074523-5ec3-45c5-8af5-188f2286ddbb)

**Особенности:**
- Переиспользуемый компонент, который можно интегрировать в различные части приложения.
- Анимация переворота карточек с использованием SwiftUI.
- Управление состоянием карточек и обработка событий свайпа.
- Легко настраиваемые размеры и длительность анимации.
- Картинки на карточку подгружаются через Kingfisher с Unsplash

**Пример использования:**
```swift
CardStackView(
    words: words.filter { !$0.isLearned },
    onLearnAgain: { word in
        // Логика для повторного изучения слова
    },
    onSuccessfullyLearned: { word in
        // Логика для успешного изучения слова
    },
    onEndLearning: {
        // Логика для завершения процесса изучения
    }
)
```

#### Переиспользуемый компонент `TextInputView`

**Описание:** `TextInputView` - это компонент для ввода текста, который включает текстовое поле и кнопку для сканирования текста с камеры. Этот компонент позволяет пользователям вводить слова вручную или сканировать их с помощью камеры.

<img width="320" alt="image" src="https://github.com/KASAFF/SnapLearn/assets/91468100/991717a0-32a7-47ce-9c9e-767ed31818c8">

**Особенности:**
- Переиспользуемый компонент, который можно использовать в различных частях приложения.
- Текстовое поле с настраиваемым фоном и углами скругления.
- Кнопка для сканирования текста с камеры с использованием Live Text `captureTextFromCamera`.

**Пример использования:**
```swift
TextInputView(text: $viewModel.newWordText)
```


### 2. Повышение уровня знаний в системных фреймворках повышенной сложности

**Описание:** В проекте используется фреймворк `SwiftData` для управления данными. Это позволяет эффективно сохранять, извлекать и управлять данными слов. SwiftData обеспечивает надежное и масштабируемое решение для работы с данными в приложении.

**Использование SwiftData:**
- Сохранение новых слов в базу данных.
- Извлечение слов для отображения и изучения.
- Управление состоянием изучения слов (например, пометка слова как "выучено").

**Пример кода:**
```swift
@Environment(\.modelContext) private var modelContext

private func saveWordForFutureLearning() {
    guard let word = viewModel.wordModel, !word.wordText.isEmpty else { return }

    let wordText = word.wordText
    let predicate = #Predicate<WordModel> { wordModel in
        wordModel.wordText == wordText
    }

    do {
        let existingWords = try modelContext.fetch(.init(predicate: predicate))
        if existingWords.isEmpty {
            modelContext.insert(word)
            try modelContext.save()
            print("Word saved successfully")
        } else {
            alertMessage = "The word '\(word.wordText)' is already saved."
            showAlert = true
        }
    } catch {
        print("Failed to save word: \(error)")
        alertMessage = "Failed to save word: \(error.localizedDescription)"
        showAlert = true
    }
}
```

### Видео работоспособности

![OverallApp](https://github.com/KASAFF/SnapLearn/assets/91468100/f9ec3236-39d7-45b2-b4f2-b1d71f465c73)
