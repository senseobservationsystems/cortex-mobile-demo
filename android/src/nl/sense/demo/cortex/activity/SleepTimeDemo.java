package nl.sense.demo.cortex.activity;

import org.json.JSONObject;

import android.util.Log;
import nl.sense.demo.FragmentDisplay;
import nl.sense_os.cortex.SleepTimeSensor;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.subscription.*;
import nl.sense_os.service.shared.SensorDataPoint;

public class SleepTimeDemo {

	/** The DataProcessor */
	private SleepTimeSensor sleepTime;
	/** The name of the DataProcessor */
	public final static String TAG = "My SleepTime Demo";
	/** Connection to the SenseService **/
	private SensePlatform sensePlatform;
	
	/** The DataProcessor which handles the data coming from the SleepTime DataProcessor */
	private GetData getData;
	private Thread sendData;


	/*
	 * SleepTime Demo constructor
	 * nb. The sleepTimeSensor needs the carry device sensor as input 
	 */
	public SleepTimeDemo(SensePlatform sensePlatform)
	{			
		this.sensePlatform = sensePlatform;
		SubscriptionManager sm = SubscriptionManager.getInstance();
		// Check if the DataProcessor is already registered at the Sense Service
		if(sm.isProducerRegistered(SleepTimeDemo.TAG))
		{
			// Get the getData class which has the fragment for the display
			getData = (GetData) sm.getSubscribedConsumers(SleepTimeDemo.TAG).get(0);
			// Get the DataProcessor
			sleepTime = (SleepTimeSensor) sm.getRegisteredProducers(SleepTimeDemo.TAG).get(0);
		}
		else
		{
			// Create new GetData DataProcessor which is used to display the data on a fragment, and send it to CommonSense
			getData = new GetData(FragmentDisplay.newInstance(TAG));
			// Create the actual CarryDevice DataProcessor, which will be registered at the Sense Service with the given name (TAG)
			sleepTime = new SleepTimeSensor(TAG, sensePlatform);
			// This resets the learned noise values, when erroneous data with no variance is processed
			// the lowest variance used to determine the noise is 0 which means that the smallest change will cause an event
			//carryDevice.reCalibrate();
			sm.subscribeConsumer(TAG, getData);
			// This sets the interval at which to compute the output
			// It only produces output when new data comes in and the interval time has been exceeded.
			// Setting the interval will also reset the time window to the interval value + 10%
			// To compute the noise in the signal the buffer should have enough samples
			// when it receives samples ones every minute than a window of 1 minute does not work
			// this should then at least be 5 minutes.
			sleepTime.setInterval(30);
			// Reliable output will only be given when the buffer time has been reached
			// This time window also smoothes this signal, but when an event is found in the time window
			// this event can take the length of the time window to get the event out
			sleepTime.setTimeWindow(30);
			// this sets how much times the sensor data should be above the noise level
			// carryDevice.setEventThreshold(0.01);
			// Re-calibrate removes the learned lowest and highest variance values
			// carryDevice.reCalibrate();
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
	private class GetData implements DataConsumer
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
