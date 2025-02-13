# Указываем URL страницы, с которой будем получать случайные ссылки
$randomurl = "https://upread.ru/random_site.php"

# Создаем хэш-таблицу для хранения уникальных URL, чтобы не проверять одни и те же адреса в рамках одной сессии.
# Как показали эксперименты, наш сервис выдаёт чуть более 60 уникальных ссылок из 100 запрошенных. Для нашего эксперимента этого достаточно.
$uniqueUrls = @{}

# Путь к файлу zap.bat. Замените путь, если установили ZAP в другую папку
$zapPath = "C:\Program Files\ZAP\Zed Attack Proxy\"

# Переходим в папку ZAP
Set-Location $zapPath

# Путь к папке ZAPSCAN на рабочем столе, куда будут сохраняться отчёты
$outputDir = "$env:USERPROFILE\Desktop\ZAPSCAN"

# Проверяем, существует ли папка ZAPSCAN, если нет - создаем её
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

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
                
                # Формируем имя файла отчёта в формате сегодняшняядата_url.txt
                $date = Get-Date -Format "yyyyMMdd_HHmmss"
                $outputFile = "$outputDir\$($date)_$($baseurl -replace '[^\w]', '_').txt"

                # Выполняем команду zapit для нашего сайта и сохраняем результат в файл
                .\zap.bat -zapit $baseurl -cmd | Out-File -FilePath $outputFile
            } 
        } 
    } catch {
        # На всякий случай отлавливаем ошибки в консоли, но ошибок быть не должно
        Write-Output "Ошибка при запросе к $randomurl"
    }
} 