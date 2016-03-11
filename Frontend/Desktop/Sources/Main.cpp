#include <QApplication>

#include "MainWindow.h"

int main(int argc, char* argv[])
{
    QApplication application(argc, argv);

    application.setApplicationName(PROJECT_NAME);
    application.setOrganizationName(ORGANIZATION_NAME);
    application.setOrganizationDomain(ORGANIZATION_DOMAIN);

    application.setQuitOnLastWindowClosed(false);

    MainWindow mainWindow;
    mainWindow.show();

    return application.exec();
}
