package nl.sense.demo.intellisense.presence;

import org.json.JSONObject;

import android.util.Log;
import nl.sense_os.intellisense.dataprocessor.CarryDevice;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.shared.DataProcessor;
import nl.sense_os.service.shared.SensorDataPoint;

public class CarryDeviceDemo {

	private CarryDevice carryDevice;
	public final static String TAG = "My CarryDevice Demo";
	private SensePlatform sensePlatform;
	private Thread sendData;
	
	public CarryDeviceDemo(SensePlatform sensePlatform)
	{			
		this.sensePlatform = sensePlatform;
		carryDevice = new CarryDevice(TAG, sensePlatform.getService().getSenseService());
		// This resets the learned noise values, when erroneous data with no variance is processed
		// the lowest variance used to determine the noise is 0 which means that the smallest change will cause an event
		//carryDevice.reCalibrate();
		carryDevice.addSubscriber(new GetData());
		// This sets the interval at which to compute the output
		// It only produces output when new data comes in and the interval time has been exceeded.
		// Setting the interval will also reset the time window to the interval value + 10%
		// To compute the noise in the signal the buffer should have enough samples
		// when it receives samples ones every minute than a window of 1 minute does not work
		// this should then at least be 5 minutes.
		carryDevice.setInterval(60);
		// Reliable output will only be given when the buffer time has been reached
		// This time window also smoothes this signal, but when an event is found in the time window
		// this event can take the length of the time window to get the event out
		carryDevice.setTimeWindow(60*5);
		// this sets how much times the sensor data should be above the noise level
		carryDevice.setEventThreshold(0.01);
	}
	
	/**
	 * This Class implements a data processor to receive data from a DataProducer.
	 * 
	 * @author Ted Schmidt <ted@sense-os.nl>
	 */
	private class GetData implements DataProcessor
	{						
		
		public void startNewSample() {}
		
		public boolean isSampleComplete() {	return false;	}

		public void onNewData(SensorDataPoint dataPoint) 
		{	
			try
			{
			if(dataPoint.sensorName == TAG)
			{
				// Description of the sensor
				final String name = "carry device";
				final String displayName = TAG;
				final String dataType = "json";
				final String description = name;
				JSONObject json = dataPoint.getJSONValue();				
				
		        // the value to be sent, in json format
				final String value = json.getJSONObject("value").toString();
				final long timestamp = dataPoint.timeStamp;
				try {
					sendData = new Thread(){public void run(){
					sensePlatform.addDataPoint(name, displayName, description, dataType, value, timestamp);
					}};
					sendData.start();
				} catch (Exception e) {
		            Log.e(TAG, "Failed to add data point!", e);
				}
			}
			}catch(Exception e)
			{
				Log.e(TAG, e.getMessage());
			}
		}		
	}
}
