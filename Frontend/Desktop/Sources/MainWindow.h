#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QCompleter>
#include <QMainWindow>
#include <QStringListModel>

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
    void updateBackedUrlEdit();
    void updateIconLabel();

    void incrementMissedMessagesCount();
    void resetMissedMessagesCount();

    void handleSocketStateChange(QAbstractSocket::SocketState state);
    void appendMessage(const QString& senderId, const QString& text, const QString& type);
    void handleNewMessage();
    void sendMessage();

    void on_backedUrlEdit_returnPressed();

private:
    Ui::MainWindow* m_ui;
    QCompleter* m_backedUrlEditCompleter;
    QStringListModel* m_backedUrlCompleterModel;
    SimpleChatClient* m_simpleChatClient;
    int m_missedMessagesCount;
};

#endif // MAINWINDOW_H
