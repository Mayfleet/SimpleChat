#ifndef SIMPLECHATCLIENT_H
#define SIMPLECHATCLIENT_H

#include <QJsonObject>
#include <QWebSocket>

class SimpleChatClient : public QObject
{
    Q_OBJECT

public:
    SimpleChatClient(QObject* parent = 0);

    QString senderId() const;
    void setSenderId(const QString& value);

    void open(const QUrl& url);

public slots:
    void sendMessage(const QString& text);

signals:
    void historyMessageReceived(const QString& senderId, const QString& text, const QString& type);
    void simpleMessageReceived(const QString& senderId, const QString& text, const QString& type);

private:
    void handleHistory(const QJsonObject& message);
    void handleMessage(const QJsonObject& message);

private slots:
    void handleTextMessage(const QString& message);

private:
    QWebSocket* m_webSocket;
    QString m_senderId;
};

#endif // SIMPLECHATCLIENT_H
