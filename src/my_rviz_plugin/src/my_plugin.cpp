#include <pluginlib/class_list_macros.h>
#include <ros/ros.h>
#include <std_msgs/String.h>
#include "my_rviz_plugin/my_plugin.h"

#include <QVBoxLayout>
#include <QPushButton>
#include <QLineEdit>
#include <QLabel>
#include <QProcess>

namespace my_rviz_plugin
{

MyPlugin::MyPlugin(QWidget *parent)
    : rviz::Panel(parent)
{
    // Set up the UI layout
    QVBoxLayout *layout = new QVBoxLayout;

    // Create a label
    message_label_ = new QLabel("Enter file path and click the button:");
    layout->addWidget(message_label_);

    // Create a text box for file input
    file_input_ = new QLineEdit;
    layout->addWidget(file_input_);

    // Create a button
    button_ = new QPushButton("Run Script");
    layout->addWidget(button_);

    // Set the layout for the plugin
    setLayout(layout);

    // Connect the button signal to the slot
    connect(button_, SIGNAL(clicked()), this, SLOT(buttonClicked()));

    // Set up the ROS publisher
    ros::NodeHandle nh;
    publisher_ = nh.advertise<std_msgs::String>("my_plugin_topic", 1);
}

MyPlugin::~MyPlugin()
{
}

void MyPlugin::buttonClicked()
{
    QString file_path = file_input_->text(); // Get the file path from the text box

    if (!file_path.isEmpty())
    {
        // Full path to your script
        QString script_path = "/home/ottonomyio/worlds/catkin_ws/src/my_rviz_plugin/src/building.sh"; // Replace with the actual script path

        // Set up QProcess to run the script
        QProcess *process = new QProcess(this);

        // Prepare the command and arguments
        QString command = QString("%1 %2").arg(script_path).arg(file_path);

        ROS_INFO_STREAM("Executing script: " << command.toStdString());

        // Run the script
        process->startDetached("bash", QStringList() << "-c" << command);

        if (!process->waitForStarted())
        {
            ROS_ERROR_STREAM("Failed to start script: " << process->errorString().toStdString());
            message_label_->setText("Error: Could not run the script!");
            return;
        }
        // process->waitForFinished(-1);

        // Handle script completion
        connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
                this, [process, this](int exit_code, QProcess::ExitStatus exit_status) {
                    if (exit_status == QProcess::NormalExit && exit_code == 0)
                    {
                        ROS_INFO("Script executed successfully.");
                        message_label_->setText("Script executed successfully!");
                    }
                    else
                    {
                        ROS_ERROR_STREAM("Script execution failed with code: " << exit_code);
                        message_label_->setText("Error: Script execution failed!");
                    }
                    process->deleteLater();
                });

        // Capture output and errors
        connect(process, &QProcess::readyReadStandardOutput, this, [process]() {
            ROS_INFO_STREAM("Script output: " << process->readAllStandardOutput().toStdString());
        });

        connect(process, &QProcess::readyReadStandardError, this, [process]() {
            ROS_ERROR_STREAM("Script error: " << process->readAllStandardError().toStdString());
        });

        // Publish the file path as a ROS message
        std_msgs::String msg;
        msg.data = file_path.toStdString();
        publisher_.publish(msg);

        ROS_INFO_STREAM("Published file path: " << msg.data);
    }
    else
    {
        message_label_->setText("Please enter a valid file path.");
        ROS_WARN("No file path entered.");
    }
}

} // namespace my_rviz_plugin

// Register the panel as an RViz plugin
PLUGINLIB_EXPORT_CLASS(my_rviz_plugin::MyPlugin, rviz::Panel)
