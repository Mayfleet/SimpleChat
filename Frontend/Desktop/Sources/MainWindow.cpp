#include "MainWindow.h"
#include "ui_MainWindow.h"

#include <QSettings>

static const QUrl backendUrl("ws://localhost:3000");
//static const QUrl backendUrl("ws://mf-simple-chat.herokuapp.com");

MainWindow::MainWindow(QWidget* parent) : QMainWindow(parent),  m_ui(new Ui::MainWindow)
{
    m_ui->setupUi(this);

    m_ui->messageEdit->viewport()->setAutoFillBackground(false);
    m_ui->messageEdit->setTabChangesFocus(true);
    m_ui->messageEdit->installEventFilter(this);

    m_simpleChatClient = new SimpleChatClient(this);

    connect(m_simpleChatClient, SIGNAL(historyMessageReceived(QString,QString,QString)),
            SLOT(appendMessage(QString,QString,QString)));

    connect(m_simpleChatClient, SIGNAL(simpleMessageReceived(QString,QString,QString)),
            SLOT(appendMessage(QString,QString,QString)));

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

    if ((event->type() == QEvent::KeyPress) && (watched == m_ui->messageEdit))
    {
        QKeyEvent* keyEvent = reinterpret_cast<QKeyEvent*>(event);

        if (keyEvent->key() == Qt::Key_Return)
        {
            QMetaObject::invokeMethod(this, "sendMessage", Qt::QueuedConnection);
            return true;
        }
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
}

void MainWindow::closeEvent(QCloseEvent* event)
{
    QSettings settings;
    settings.beginGroup("MainWindow");
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

void MainWindow::appendMessage(const QString& senderId, const QString& text, const QString& type)
{
    static const QString rowTemplate("<p><b>%1</b>:<br/>%2</p>");
    QString row = rowTemplate.arg(senderId).arg(text);
    m_ui->messagesBrowser->append(row);
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
