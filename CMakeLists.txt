cmake_minimum_required(VERSION 3.21)
project(wheel_limits_cpp VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

option(WHEEL_STATIC "Link Qt statically into one exe (needs QtStatic prefix)" OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

qt_add_executable(wheel_limits_cpp
    src/main.cpp
    src/bridge.cpp
    src/bridge.h
)
target_include_directories(wheel_limits_cpp PRIVATE src)
target_link_libraries(wheel_limits_cpp PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2)
set_target_properties(wheel_limits_cpp PROPERTIES WIN32_EXECUTABLE TRUE)

set(wl_qml
    ui/qml/Main.qml
    ui/qml/SunkField.qml
    ui/qml/RaiseButton.qml
    ui/qml/IconLabel.qml
    ui/qml/WheelDropdown.qml
    ui/qml/SideDiagram.qml
)
set(wl_fonts
    assets/fonts/MaterialIcons-Regular.ttf
    assets/fonts/NotoSansThaiLooped.ttf
    assets/fonts/NotoSans-Regular.ttf
)
set(wl_fleet
    assets/fleet/als.png
    assets/fleet/gek.png
    assets/fleet/hid.png
    assets/fleet/gea.png
    assets/fleet/csr.png
    assets/fleet/qsy.png
)
foreach(f ${wl_qml})
    get_filename_component(n ${f} NAME)
    set_source_files_properties(${f} PROPERTIES QT_RESOURCE_ALIAS qml/${n})
endforeach()
foreach(f ${wl_fonts})
    get_filename_component(n ${f} NAME)
    set_source_files_properties(${f} PROPERTIES QT_RESOURCE_ALIAS fonts/${n})
endforeach()
foreach(f ${wl_fleet})
    get_filename_component(n ${f} NAME)
    set_source_files_properties(${f} PROPERTIES QT_RESOURCE_ALIAS fleet/${n})
endforeach()
qt_add_resources(wheel_limits_cpp wheel PREFIX /wheel FILES ${wl_qml} ${wl_fonts} ${wl_fleet})

if(WHEEL_STATIC)
    qt_import_qml_plugins(wheel_limits_cpp)
    target_link_options(wheel_limits_cpp PRIVATE -static -static-libgcc -static-libstdc++)
endif()

add_executable(check_calc checks/check_calc.cpp)
target_include_directories(check_calc PRIVATE src)

add_executable(check_undo checks/check_undo.cpp)
target_include_directories(check_undo PRIVATE src)

add_executable(check_font checks/check_font.cpp)
target_link_libraries(check_font PRIVATE Qt6::Core Qt6::Gui)
