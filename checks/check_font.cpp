#undef NDEBUG
#include <QGuiApplication>
#include <QFontDatabase>
#include <QFont>
#include <QFile>
#include <cassert>
#include <cstdio>

static QString load(const QString& path) {
    std::printf("exists %s -> %d\n", qPrintable(path), QFile::exists(path) ? 1 : 0);
    const int id = QFontDatabase::addApplicationFont(path);
    std::printf("id=%d\n", id);
    if (id < 0) return {};
    const auto fams = QFontDatabase::applicationFontFamilies(id);
    for (const auto& f : fams) std::printf("  family: [%s]\n", qPrintable(f));
    return fams.value(0);
}

int main(int argc, char** argv) {
    QGuiApplication app(argc, argv);
    const QString disk = QStringLiteral("C:/trs22/wheel_limits_cpp/assets/fonts/NotoSansThaiLooped.ttf");
    const QString fam = load(disk);
    assert(!fam.isEmpty());
    QFont font(fam);
    font.setPixelSize(16);
    std::printf("QFont family asked=[%s] actual=[%s] exactMatch=%d\n",
                qPrintable(fam), qPrintable(font.family()), font.exactMatch() ? 1 : 0);
    // comma form — often broken in Qt
    QFont bad(fam + QStringLiteral(", Noto Sans"));
    std::printf("comma form family=[%s] exactMatch=%d\n", qPrintable(bad.family()), bad.exactMatch() ? 1 : 0);
    std::puts("check_font: ok");
    return 0;
}
