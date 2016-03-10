#include "SimpleChatClient.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

SimpleChatClient::SimpleChatClient(QObject* parent) : QObject(parent)
{
    m_webSocket = new QWebSocket("SimpleChatDesktopClient", QWebSocketProtocol::VersionLatest, this);
    connect(m_webSocket, SIGNAL(textMessageReceived(QString)), SLOT(handleTextMessage(QString)));

    m_senderId = QString("Desktop Client #%1").arg(qrand() % 1000);
}

QString SimpleChatClient::senderId() const
{
    return m_senderId;
}

void SimpleChatClient::setSenderId(const QString& value)
{
    m_senderId = value;
}

QUrl SimpleChatClient::backedUrl() const
{
    return m_backedUrl;
}

void SimpleChatClient::open(const QUrl& backedUrl)
{
    m_backedUrl = backedUrl;
    m_webSocket->close();

    if (backedUrl.isValid())
    {
        m_backedUrl.setScheme("ws");
        m_webSocket->open(m_backedUrl);
    }

    emit backendUrlChanged();
}

void SimpleChatClient::sendMessage(const QString& text)
{
    QJsonObject messageObject;
    messageObject.insert("type", "message");
    messageObject.insert("senderId", m_senderId);
    messageObject.insert("text", text);

    QJsonDocument messageDocument(messageObject);
    QString json = messageDocument.toJson(QJsonDocument::Compact);

    m_webSocket->sendTextMessage(json);
}

void SimpleChatClient::handleHistory(const QJsonObject& message)
{
    QJsonArray messages = message.value("messages").toArray();
    int messagesCount = messages.count();

    for (int i = 0; i < messagesCount; i++)
    {
        QJsonObject historyMessage = messages.at(i).toObject();
        QString senderId = historyMessage.value("senderId").toString();
        QString text = historyMessage.value("text").toString();
        QString type = historyMessage.value("type").toString();
        emit historyMessageReceived(senderId, text, type);
    }
}

void SimpleChatClient::handleMessage(const QJsonObject& message)
{
    QString senderId = message.value("senderId").toString();
    QString text = message.value("text").toString();
    QString type = message.value("type").toString();
    emit simpleMessageReceived(senderId, text, type);
}

void SimpleChatClient::handleTextMessage(const QString& message)
{
    QJsonParseError parseError;
    QJsonDocument messageDocument = QJsonDocument::fromJson(message.toUtf8(), &parseError);

    if (parseError.error)
    {
        qWarning() << "Unable to parse SimpleChat message:" << message;
        return;
    }

    if (!messageDocument.isObject())
    {
        qWarning() << "Invalid SimpleChat message (not a JSON object):" << message;
        return;
    }

    QJsonObject messageObject = messageDocument.object();
    QString messageType = messageObject.value("type").toString();

    if (messageType == "history")
    {
        handleHistory(messageObject);
    }
    else if (messageType == "message")
    {
        handleMessage(messageObject);
    }
    else
    {
        qWarning() << "Unsupported message type:" << message;
        return;
    }
}
