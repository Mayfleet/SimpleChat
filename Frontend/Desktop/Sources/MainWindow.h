#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

#include "SimpleChatClient.h"

namespace Ui
{
    class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget* parent = 0);
    ~MainWindow();

public:
    bool eventFilter(QObject* watched, QEvent* event);

protected:
    void showEvent(QShowEvent* event);
    void closeEvent(QCloseEvent* event);

private slots:
    void adjustDocumentMargins();
    void handleBackendUrlChange();
    void updateAddressEdit();

    void appendMessage(const QString& senderId, const QString& text, const QString& type);
    void sendMessage();

    void on_addressEdit_returnPressed();

private:
    Ui::MainWindow* m_ui;
    SimpleChatClient* m_simpleChatClient;
};

#endif // MAINWINDOW_H
