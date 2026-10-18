#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QDebug>
#include "bridge.h"
int main(int argc, char** argv) {
    qputenv("QT_LOGGING_RULES", "qt.qml=true;qt.quick=true");
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("Basic"));
    Bridge bridge;
    bridge.applyApplicationFont();
    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::warnings, [](const QList<QQmlError>& warns) {
        for (const auto& w : warns) qWarning() << w.toString();
    });
    engine.rootContext()->setContextProperty(QStringLiteral("bridge"), &bridge);
    engine.load(QUrl(QStringLiteral("qrc:/wheel/qml/Main.qml")));
    qWarning() << "roots" << engine.rootObjects().size();
    if (engine.rootObjects().isEmpty()) return 2;
    return app.exec();
}
