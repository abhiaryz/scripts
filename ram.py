import psutil
import time
from psutil._common import bytes2human
#Function for getting ram usage
def virtual_ram():
    result={}
    mem = psutil.virtual_memory()
    result['total']=bytes2human(mem.total)
    result['available']=bytes2human(mem.available)
    result['percent']=mem.percent
    result['used']=bytes2human(mem.used)
    result['free']=bytes2human(mem.free)
    return result 

while True:
    a=virtual_ram()
    b=float(a['percent'])
    time.sleep(1)
    if(b>75):
        print("Ram usage is high with %",b)
    else:
        print("Ram usage is normal with ",b,"%") 
