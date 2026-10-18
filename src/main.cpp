#include "bridge.h"

#include <QCursor>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlError>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QScreen>
#include <cstdio>

namespace {

void centerOnWorkArea(QQuickWindow* win) {
    if (!win)
        return;

    QScreen* screen = QGuiApplication::screenAt(QCursor::pos());
    if (!screen)
        screen = win->screen();
    if (!screen)
        screen = QGuiApplication::primaryScreen();
    if (!screen)
        return;

    const QRect ag = screen->availableGeometry();
    int w = win->width();
    int h = win->height();
    // Fit inside work area without forcing a phone aspect ratio.
    if (w > ag.width() - 24)
        w = ag.width() - 24;
    if (h > ag.height() - 24)
        h = ag.height() - 24;
    w = qMax(900, w);
    h = qMax(560, h);
    if (w > ag.width() - 24)
        w = ag.width() - 24;
    if (h > ag.height() - 24)
        h = ag.height() - 24;
    win->resize(w, h);

    const int x = ag.x() + (ag.width() - w) / 2;
    const int y = ag.y() + (ag.height() - h) / 2;
    win->setPosition(x, y);
}

}  // namespace

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("wheel_limits"));
    QGuiApplication::setApplicationDisplayName(QStringLiteral("พิกัดล้อ"));
    QGuiApplication::setOrganizationName(QStringLiteral("MSTN"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    Bridge bridge;
    bridge.applyApplicationFont();

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::warnings, [](const QList<QQmlError>& warns) {
        for (const QQmlError& w : warns)
            std::fprintf(stderr, "qml: %s\n", qPrintable(w.toString()));
    });
    engine.rootContext()->setContextProperty(QStringLiteral("bridge"), &bridge);
    engine.load(QUrl(QStringLiteral("qrc:/wheel/qml/Main.qml")));
    if (engine.rootObjects().isEmpty()) {
        std::fprintf(stderr, "wheel_limits: Main.qml failed to load (no root objects)\n");
        return 1;
    }

    auto* win = qobject_cast<QQuickWindow*>(engine.rootObjects().constFirst());
    if (!win) {
        std::fprintf(stderr, "wheel_limits: root is not a Window\n");
        return 1;
    }
    centerOnWorkArea(win);
    win->show();

    return app.exec();
}
