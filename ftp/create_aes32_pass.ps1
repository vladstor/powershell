<#
    Срiпт для створення зашифрованного пароля i ключа для розшифрування
    зашифрований пароль з ключем можна перемiщати мiж комп'ютерами
#>

$Cred = Get-Credential
$aes32key_file = '/home/pi/ftp/aes32.key'
$pass_file = '/home/pi/ftp/pass.txt'

# Створю ключ AES32 для шифрування паролю
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
$AESKey | out-file $aes32key_file

# Зберігаю зашифрований пароль ключом AES32 в файл
$Cred.Password | ConvertFrom-SecureString -Key (get-content $aes32key_file) | Set-Content $pass_file

<#
    # Зашифрований пароль можна отримати в iншому скрiптi
    
    $aes32key_file = '/home/pi/ftp/aes32.key'
    $pass_file = '/home/pi/ftp/aes32.key'
    $pass = Get-Content $pass_file | ConvertTo-SecureString -Key (get-content $aes32key_file)
#>
