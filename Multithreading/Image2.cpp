#include <opencv2/opencv.hpp>
#include <iostream>
// Compile with g++ Image2.cpp -lopencv_core -lopencv_highgui -lopencv_imgproc

int main()
{
    cv::Mat src = cv::imread("im.bmp", CV_LOAD_IMAGE_UNCHANGED);
    cv::Mat dst;

    cv::Point2f pc(src.cols/2., src.rows/2.);
    cv::Mat r = cv::getRotationMatrix2D(pc, -45, 1.0);

    cv::warpAffine(src, dst, r, src.size()); // what size I should use?

    cv::imwrite("rotated_im.png", dst);

    return 0;
}