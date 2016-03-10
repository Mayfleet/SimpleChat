#include "MainWindow.h"
#include "ui_MainWindow.h"

#include <QScrollBar>
#include <QSettings>

static const QUrl defaultBackendUrl("ws://mf-simple-chat.herokuapp.com");

static QColor getTextColor(const QString& text);

MainWindow::MainWindow(QWidget* parent) : QMainWindow(parent),  m_ui(new Ui::MainWindow)
{
    m_ui->setupUi(this);

    m_ui->addressEdit->setAttribute(Qt::WA_MacShowFocusRect, false);
    m_ui->addressEdit->installEventFilter(this);

    connect(m_ui->addressEdit, SIGNAL(editingFinished()), SLOT(updateAddressEdit()));

    m_ui->messageEdit->viewport()->setAutoFillBackground(false);
    m_ui->messageEdit->setTabChangesFocus(true);
    m_ui->messageEdit->installEventFilter(this);

    m_simpleChatClient = new SimpleChatClient(this);

    connect(m_simpleChatClient, SIGNAL(backendUrlChanged()), SLOT(handleBackendUrlChange()));

    connect(m_simpleChatClient, SIGNAL(historyMessageReceived(QString,QString,QString)),
            SLOT(appendMessage(QString,QString,QString)));

    connect(m_simpleChatClient, SIGNAL(simpleMessageReceived(QString,QString,QString)),
            SLOT(appendMessage(QString,QString,QString)));

    QSettings settings;
    settings.beginGroup("MainWindow");

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

        if ((watched == m_ui->addressEdit) && (key == Qt::Key_Escape))
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
    else if ((eventType == QEvent::FocusIn) && (watched == m_ui->addressEdit))
    {
        QMetaObject::invokeMethod(m_ui->addressEdit, "selectAll", Qt::QueuedConnection);
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
    updateAddressEdit();
    m_ui->messagesBrowser->clear();
    m_ui->messageEdit->setFocus();
}

void MainWindow::updateAddressEdit()
{
    QUrl backendUrl = m_simpleChatClient->backedUrl();
    m_ui->addressEdit->setText(backendUrl.toString());
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

void MainWindow::sendMessage()
{
    QString message = m_ui->messageEdit->toPlainText().trimmed();

    if (!message.isEmpty())
    {
        m_simpleChatClient->sendMessage(m_ui->messageEdit->toPlainText());
    }

    m_ui->messageEdit->clear();
}

void MainWindow::on_addressEdit_returnPressed()
{
    QUrl backendUrl = QUrl::fromUserInput(m_ui->addressEdit->text());
    m_simpleChatClient->open(backendUrl);
}

// Utilities

QColor getTextColor(const QString& text)
{
    QByteArray hash = QCryptographicHash::hash(text.toUtf8(), QCryptographicHash::Sha1);
    quint16 trimmedHash = *(const quint16*)hash.data();
    return QColor::fromHsv(qBound(0, trimmedHash % 37 * 10, 359), 190, 150);
}
