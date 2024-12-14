#ifndef MY_RVIZ_PLUGIN_H
#define MY_RVIZ_PLUGIN_H

#include <ros/ros.h>
#include <rviz/panel.h>

class QLabel;
class QPushButton;
class QLineEdit;

namespace my_rviz_plugin
{

    class MyPlugin : public rviz::Panel
    {
        Q_OBJECT
    public:
        MyPlugin(QWidget *parent = 0);
        virtual ~MyPlugin();

    protected Q_SLOTS:
        void buttonClicked();

    protected:
        ros::Publisher publisher_;      // ROS Publisher for sending messages
        QLabel *message_label_;         // Label to display messages
        QPushButton *button_;           // Button to trigger the script
        QLineEdit *file_input_;         // Text box for file input
    };

} // namespace my_rviz_plugin

#endif // MY_RVIZ_PLUGIN_H
