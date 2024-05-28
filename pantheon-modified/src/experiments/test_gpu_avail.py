import tensorflow as tf

# 检查 TensorFlow 的版本
print("TensorFlow version:", tf.__version__)

# 检查可用的 GPU
from tensorflow.python.client import device_lib
print("Available devices:")
print(device_lib.list_local_devices())

# 创建一个张量并将其送到GPU
with tf.device('/gpu:0'):
    array = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0])
    print("Array:", array)

# 检查该数组的设备
sess = tf.Session(config=tf.ConfigProto(log_device_placement=True))
with sess.as_default():
    result = array.eval()
    print("Array is on device:", array.device)

