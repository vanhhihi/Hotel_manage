@echo off
chcp 65001
echo Dang compile...

javac -cp "E:\2025.2\tomcat\tomcat\lib\servlet-api.jar;myweb\WEB-INF\lib\mysql-connector-j-8.2.0.jar" -d myweb\WEB-INF\classes src\controller\LoginServlet.java src\controller\RegisterServlet.java src\controller\LogoutServlet.java src\controller\RoomServlet.java

if %errorlevel% == 0 (
    echo Compile thanh cong!
) else (
    echo Compile that bai! Kiem tra lai code.
)

pause