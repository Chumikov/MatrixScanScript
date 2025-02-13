# Укажите путь к папке с файлами
$folderPath = "C:\Users\chumi\Desktop\ZAPSCAN"

# Получаем все txt файлы в указанной папке
$files = Get-ChildItem -Path $folderPath -Filter *.txt

# Перебираем каждый файл
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName
    $newName = $file.Name

    # Проверяем наличие слова "High" в файле
    if ($content -match '\bHigh\b') {
        $newName = "H" + $newName
    }

    # Проверяем наличие строки "PHP (VER)" в файле
    if ($content -match "PHP \(7\.3\.33\)") {
        $newName = "+" + $newName
    }

    # Добавьте другие условия по аналогии
    # if ($content -match "AnotherPattern") {
    #     $newName = "AnotherPrefix" + $newName
    # }

    # Если имя файла изменилось, переименовываем файл
    if ($newName -ne $file.Name) {
        $newPath = Join-Path -Path $folderPath -ChildPath $newName
        Rename-Item -Path $file.FullName -NewName $newPath
    }
}