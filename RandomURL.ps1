# Указываем URL страницы, с которой будем получать случайные ссылки
$randomurl = "https://upread.ru/random_site.php"

# Создаем хэш-таблицу для хранения уникальных URL, чтобы не проверять одни и те же адреса в рамках одной сессии.
# Как показали эксперименты, наш сервис выдаёт чуть более 60 уникальных ссылок из 100 запрошенных. Для нашего эксперимента этого достаточно.
$uniqueUrls = @{}

# Бесконечный Цикл, который можно разорвать только принудительно 
while ($true) {
    try {
        # Выполняем запрос к странице и получаем HTML-контент
        $response = Invoke-WebRequest -Uri $randomurl -ErrorAction Stop
        #Получаем весь HTML-контент страницы
        $htmlContent = $response.Content

        # Используем регулярное выражение для поиска URL в HTML-контенте
        # Ищем ссылки, заканчивающиеся на /favicon.ico, и захватываем основную часть URL (этот способ подобран экспериментально)
        $urlPattern = '(https?://[^"\s]+)/favicon\.ico'
        $match = [regex]::Match($htmlContent, $urlPattern)

        # Если URL найден
        if ($match.Success) {
            $baseUrl = $match.Groups[1].Value  # Извлекаем основную часть URL (без /favicon.ico)

            # Проверяем, был ли этот URL уже сохранён
            if (-not $uniqueUrls.ContainsKey($baseUrl)) {
                $uniqueUrls[$baseUrl] = $true  # Добавляем URL в хэш-таблицу
                
                Write-Output "Найден уникальный URL: $baseUrl" #это, собственно то место, где мы получили уникальный URL
            } 
        } 
    } catch {
        # На всякий случай отлавливаем ошибки и показываем их в консоли
        Write-Output "Ошибка при запросе к $randomurl"
    }
}