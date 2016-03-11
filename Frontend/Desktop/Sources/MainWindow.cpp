#include "MainWindow.h"
#include "ui_MainWindow.h"

#include <QScrollBar>
#include <QSettings>

#ifdef Q_OS_MAC
#include <QtMac>
#endif

static const QUrl defaultBackendUrl("wss://mf-simple-chat.herokuapp.com");

static QColor getTextColor(const QString& text);

MainWindow::MainWindow(QWidget* parent) : QMainWindow(parent),  m_ui(new Ui::MainWindow)
{
    m_ui->setupUi(this);

    setWindowTitle(tr("%1 v%2").arg(APPLICATION_TITLE).arg(VERSION_SHORT));

    m_ui->backedUrlEdit->setAttribute(Qt::WA_MacShowFocusRect, false);
    m_ui->backedUrlEdit->installEventFilter(this);

    connect(m_ui->backedUrlEdit, SIGNAL(editingFinished()), SLOT(updateBackedUrlEdit()));

    m_backedUrlEditCompleter = new QCompleter(this);
    m_backedUrlCompleterModel = new QStringListModel(this);
    m_backedUrlEditCompleter->setModel(m_backedUrlCompleterModel);
    m_backedUrlEditCompleter->setCaseSensitivity(Qt::CaseInsensitive);
    m_ui->backedUrlEdit->setCompleter(m_backedUrlEditCompleter);

    m_ui->messageEdit->viewport()->setAutoFillBackground(false);
    m_ui->messageEdit->setTabChangesFocus(true);
    m_ui->messageEdit->installEventFilter(this);

    m_simpleChatClient = new SimpleChatClient(this);

    connect(m_simpleChatClient, SIGNAL(backendUrlChanged()), SLOT(handleBackendUrlChange()));

    connect(m_simpleChatClient, SIGNAL(socketStateChanged(QAbstractSocket::SocketState)),
            SLOT(handleSocketStateChange(QAbstractSocket::SocketState)));

    connect(m_simpleChatClient, SIGNAL(historyMessageReceived(QString,QString,QString)),
            SLOT(appendMessage(QString,QString,QString)));

    connect(m_simpleChatClient, SIGNAL(simpleMessageReceived(QString,QString,QString)),
            SLOT(appendMessage(QString,QString,QString)));

    connect(m_simpleChatClient, SIGNAL(simpleMessageReceived(QString,QString,QString)), SLOT(handleNewMessage()));

    m_missedMessagesCount = 0;

    qApp->installEventFilter(this);

    QSettings settings;
    settings.beginGroup("MainWindow");

    QStringList knownBackendUrls = settings.value("knownBackendUrls").toStringList();
    m_backedUrlCompleterModel->setStringList(knownBackendUrls);

    QUrl backendUrl = settings.value("backendUrl", defaultBackendUrl).toUrl();
    m_simpleChatClient->open(backendUrl);

    QMetaObject::invokeMethod(this, "adjustDocumentMargins", Qt::QueuedConnection);
}

MainWindow::~MainWindow()
{
    delete m_ui;
}

bool MainWindow::eventFilter(QObject* watched, QEvent* event)
{
    if (QMainWindow::eventFilter(watched, event))
    {
        return true;
    }

    QEvent::Type eventType = event->type();

    if (eventType == QEvent::KeyPress)
    {
        QKeyEvent* keyEvent = reinterpret_cast<QKeyEvent*>(event);
        int key = keyEvent->key();

        if ((watched == m_ui->backedUrlEdit) && (key == Qt::Key_Escape))
        {
            QMetaObject::invokeMethod(m_ui->messageEdit, "setFocus", Qt::QueuedConnection);
            return true;
        }

        if ((watched == m_ui->messageEdit) && (key == Qt::Key_Return))
        {
            QMetaObject::invokeMethod(this, "sendMessage", Qt::QueuedConnection);
            return true;
        }
    }
    else if (watched == m_ui->backedUrlEdit)
    {
        switch (eventType)
        {
        case QEvent::FocusIn:
            m_ui->backedUrlEdit->setProperty("mouseButtonPressTime", QDateTime::currentMSecsSinceEpoch());
            break;
        case QEvent::MouseMove:
            m_ui->backedUrlEdit->setProperty("mouseButtonPressTime", 0);
            break;
        case QEvent::MouseButtonRelease:
        {
            qint64 mouseButtonPressTime = m_ui->backedUrlEdit->property("mouseButtonPressTime").toLongLong();

            if (QDateTime::currentMSecsSinceEpoch() - mouseButtonPressTime < 300)
            {
                QMetaObject::invokeMethod(m_ui->backedUrlEdit, "selectAll", Qt::QueuedConnection);
            }

            break;
        }
        default:
            break;
        }
    }
    else if ((eventType == QEvent::ApplicationActivate) && (watched == QCoreApplication::instance()))
    {
        if (!isVisible())
        {
            QMetaObject::invokeMethod(this, "show", Qt::QueuedConnection);
        }

        QMetaObject::invokeMethod(this, "resetMissedMessagesCount", Qt::QueuedConnection);
    }

    return false;
}

void MainWindow::showEvent(QShowEvent* event)
{
    QSettings settings;
    settings.beginGroup("MainWindow");

    if (settings.contains("position") && settings.contains("size"))
    {
        move(settings.value("position").toPoint());
        resize(settings.value("size").toSize());
    }

    QMainWindow::showEvent(event);
    m_ui->messageEdit->setFocus();
}

void MainWindow::closeEvent(QCloseEvent* event)
{
    QSettings settings;
    settings.beginGroup("MainWindow");

    QStringList knownBackendUrls = m_backedUrlCompleterModel->stringList();
    settings.setValue("knownBackendUrls", knownBackendUrls);

    QUrl backendUrl = m_simpleChatClient->backedUrl();
    settings.setValue("backendUrl", backendUrl);

    settings.setValue("position", pos());
    settings.setValue("size", size());
    event->accept();
}

void MainWindow::adjustDocumentMargins()
{
    QTextDocument* messagesEditDocument = m_ui->messageEdit->document();
    messagesEditDocument->setDocumentMargin(9);

    QPoint anchorPoint = m_ui->messageEdit->viewport()->mapToGlobal(QPoint(messagesEditDocument->documentMargin(), 0));
    anchorPoint = m_ui->messagesBrowser->viewport()->mapFromGlobal(anchorPoint);

    QTextDocument* messagesBrowserDocument = m_ui->messagesBrowser->document();
    messagesBrowserDocument->setDocumentMargin(anchorPoint.x());
}

void MainWindow::handleBackendUrlChange()
{
    updateBackedUrlEdit();

    QString backendUrl = m_simpleChatClient->backedUrl().toString();
    QStringList knownBackendUrls = m_backedUrlCompleterModel->stringList();

    if (!knownBackendUrls.contains(backendUrl))
    {
        knownBackendUrls.prepend(backendUrl);
        m_backedUrlCompleterModel->setStringList(knownBackendUrls);
    }

    m_ui->messagesBrowser->clear();
    m_ui->messageEdit->setFocus();
}

void MainWindow::updateBackedUrlEdit()
{
    QUrl backendUrl = m_simpleChatClient->backedUrl();
    m_ui->backedUrlEdit->setText(backendUrl.toString());
}

void MainWindow::updateIconLabel()
{
    QString iconLabelText;

    if (m_missedMessagesCount > 20)
    {
        iconLabelText = "20+";
    }
    else if (m_missedMessagesCount > 0)
    {
        iconLabelText = QString::number(m_missedMessagesCount);
    }

#ifdef Q_OS_MAC
        QtMac::setBadgeLabelText(iconLabelText);
#endif

    // TODO: Implement similar indication on Windows and Linux
}

void MainWindow::incrementMissedMessagesCount()
{
    m_missedMessagesCount++;
    updateIconLabel();
}

void MainWindow::resetMissedMessagesCount()
{
    m_missedMessagesCount = 0;
    updateIconLabel();
}

void MainWindow::handleSocketStateChange(QAbstractSocket::SocketState state)
{
    static QMap<QAbstractSocket::SocketState, QString> stateCaptionsMap;

    if (stateCaptionsMap.isEmpty())
    {
        stateCaptionsMap.insert(QAbstractSocket::UnconnectedState, "Unconnected");
        stateCaptionsMap.insert(QAbstractSocket::HostLookupState, "Host Lookup...");
        stateCaptionsMap.insert(QAbstractSocket::ConnectingState, "Connecting...");
        stateCaptionsMap.insert(QAbstractSocket::ConnectedState, "Connected");
        stateCaptionsMap.insert(QAbstractSocket::BoundState, "Bound");
        stateCaptionsMap.insert(QAbstractSocket::ListeningState, "Listening");
        stateCaptionsMap.insert(QAbstractSocket::ClosingState, "Closing");

        QFontMetrics stateLabelFontMetrics(m_ui->stateLabel->font());
        int maximumCaptionWidth = 0;

        foreach (QString stateCaption, stateCaptionsMap.values())
        {
            maximumCaptionWidth = qMax(maximumCaptionWidth, stateLabelFontMetrics.width(stateCaption));
        }

        m_ui->stateLabel->setMinimumWidth(maximumCaptionWidth);
    }

    m_ui->stateLabel->setText(stateCaptionsMap.value(state));
}

void MainWindow::appendMessage(const QString& senderId, const QString& text, const QString& type)
{
    static const QString messageHtmlTemplate("<p><b style=\"color:%3;\">%1</b>:<br/>%2</p>");

    QString filteredText = text;
    filteredText.replace("<", "&lt;");
    filteredText.replace(">", "&gt;");
    filteredText.replace(QRegExp("((?:https?|ftp)://\\S+)"), "<a href=\"\\1\">\\1</a>");

    QString senderColor = getTextColor(senderId).name();
    QString messageHtml = messageHtmlTemplate.arg(senderId).arg(filteredText).arg(senderColor);
    m_ui->messagesBrowser->append(messageHtml);

    QScrollBar* messagesBrowserVerticalScrollBar = m_ui->messagesBrowser->verticalScrollBar();
    messagesBrowserVerticalScrollBar->setValue(messagesBrowserVerticalScrollBar->maximum());
}

void MainWindow::handleNewMessage()
{
    if (!isActiveWindow())
    {
        incrementMissedMessagesCount();
    }
}

void MainWindow::sendMessage()
{
    QString message = m_ui->messageEdit->toPlainText().trimmed();

    if (!message.isEmpty())
    {
        m_simpleChatClient->sendMessage(m_ui->messageEdit->toPlainText());
    }

    m_ui->messageEdit->clear();
}

void MainWindow::on_backedUrlEdit_returnPressed()
{
    QUrl backendUrl = QUrl::fromUserInput(m_ui->backedUrlEdit->text());
    m_simpleChatClient->open(backendUrl);
}

// Utilities

QColor getTextColor(const QString& text)
{
    QByteArray hash = QCryptographicHash::hash(text.toUtf8(), QCryptographicHash::Sha1);
    quint16 trimmedHash = *(const quint16*)hash.data();
    return QColor::fromHsv(qBound(0, trimmedHash % 37 * 10, 359), 190, 150);
}
