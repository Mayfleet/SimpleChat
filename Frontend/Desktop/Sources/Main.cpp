#include <QApplication>
#include <QLocalServer>
#include <QLocalSocket>

#include "MainWindow.h"

int main(int argc, char* argv[])
{
    QApplication application(argc, argv);

    application.setApplicationName(PROJECT_NAME);
    application.setOrganizationName(ORGANIZATION_NAME);
    application.setOrganizationDomain(ORGANIZATION_DOMAIN);

    // Check for other instances already running

    QLocalSocket singleInstanceSocket;
    singleInstanceSocket.connectToServer(PROJECT_NAME);

    if (singleInstanceSocket.waitForConnected(500))
    {
        singleInstanceSocket.close();
        qCritical() << "Application is already started";
        return EXIT_FAILURE;
    }

    // Initialize single instance server to prevent other instances to start

    QLocalServer::removeServer(PROJECT_NAME);
    QLocalServer singleInstanceServer;

    if (!singleInstanceServer.listen(PROJECT_NAME))
    {
        qCritical() << "Unable to start single instance server";
        return EXIT_FAILURE;
    }

    application.setQuitOnLastWindowClosed(false);

    MainWindow mainWindow;
    mainWindow.show();

    return application.exec();
}
