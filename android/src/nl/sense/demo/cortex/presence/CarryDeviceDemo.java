package nl.sense.demo.cortex.presence;

import org.json.JSONObject;

import android.util.Log;
import nl.sense.demo.FragmentDisplay;
import nl.sense_os.cortex.dataprocessor.CarryDevice;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.shared.DataProcessor;
import nl.sense_os.service.shared.SensorDataPoint;

public class CarryDeviceDemo {

	private CarryDevice carryDevice;
	public final static String TAG = "My CarryDevice Demo";
	private SensePlatform sensePlatform;
	private Thread sendData;
	private GetData getData;

	public CarryDeviceDemo(SensePlatform sensePlatform)
	{			
		this.sensePlatform = sensePlatform;
		// Check if the DataProcessor is already registered at the Sense Service
		if(sensePlatform.getService().getSenseService().isDataProducerRegistered(CarryDeviceDemo.TAG))
		{
			// Get the getData class which has the fragment for the display
			getData = (GetData) sensePlatform.getService().getSenseService().getSubscribedDataProcessor(CarryDeviceDemo.TAG).get(0);
			// Get the DataProcessor
			carryDevice = (CarryDevice) sensePlatform.getService().getSenseService().getRegisteredDataProducer(CarryDeviceDemo.TAG).get(0);
		}
		else
		{
			// Create new GetData DataProcessor which is used to display the data on a fragment, and send it to CommonSense
			getData = new GetData(FragmentDisplay.newInstance(TAG));
			carryDevice = new CarryDevice(TAG, sensePlatform.getService().getSenseService());
			// This resets the learned noise values, when erroneous data with no variance is processed
			// the lowest variance used to determine the noise is 0 which means that the smallest change will cause an event
			//carryDevice.reCalibrate();
			sensePlatform.getService().getSenseService().subscribeDataProcessor(TAG, getData);
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
	}

	/**
	 * Get the fragment object.
	 * 
	 * The fragment keeps the data from the moment the service was started.
	 * The fragment displays the data coming from the Data Processor in a table
	 * 
	 * @return FragmentDisplay
	 */
	public FragmentDisplay getFragment()
	{
		return getData.fDisplay;
	}

	/**
	 * This Class implements a data processor to receive data from a DataProducer.
	 * 
	 * @author Ted Schmidt <ted@sense-os.nl>
	 */
	private class GetData implements DataProcessor
	{						
		public FragmentDisplay fDisplay;

		GetData(FragmentDisplay fDisplay)
		{
			this.fDisplay = fDisplay;
		}
		public void startNewSample() {}

		public boolean isSampleComplete() {	return false;	}

		public void onNewData(SensorDataPoint dataPoint) 
		{	
			try
			{
				if(dataPoint.sensorName == TAG)
				{
					// Description of the sensor
					// This is only used to send data to CommonSense
					final String name = "carry device";
					final String displayName = TAG;
					final String dataType = "json";
					final String description = name;
					JSONObject json = dataPoint.getJSONValue();				

					// the value to be sent, in json format
					final String value = json.getJSONObject("value").toString();
					
					// Add data to the fragment display
					fDisplay.addText(value);
					final long timestamp = dataPoint.timeStamp;
					
					// Only try to send data when the service is bound
					if(sensePlatform.getService().isBinderAlive())
					{
						try {
							sendData = new Thread(){public void run(){
								sensePlatform.addDataPoint(name, displayName, description, dataType, value, timestamp);
							}};
							sendData.start();
						} catch (Exception e) {
							Log.e(TAG, "Failed to add data point!", e);
						}
					}
				}
			}catch(Exception e)
			{
				Log.e(TAG, e.getMessage());
			}
		}		
	}
}