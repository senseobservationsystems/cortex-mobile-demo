package nl.sense.demo.cortex.activity;

import android.util.Log;
import nl.sense.demo.FragmentDisplay;
import nl.sense.demo.cortex.presence.CarryDeviceDemo;
import nl.sense_os.cortex.FallSensor;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.subscription.*;
import nl.sense_os.service.shared.SensorDataPoint;
/**
 * This is a demo implementation of the FallDetect Data Processor of the Sense Cortex Library
 *  
 * @author Ted Schmidt
 *
 */
public class FallDetectDemo {

	/** The DataProcessor */
	private FallSensor fallDetect;
	/** The name of the DataProcessor */
	private static String TAG = "My Fall Detect Demo";
	/** Connection to the SenseService **/
	private SensePlatform sensePlatform;

	/** The DataProcessor which handles the data coming from the FallDetect DataProcessor */
	private GetData getData;
	Thread sendData;

	public FallDetectDemo(SensePlatform sensePlatform)
	{		
		this.sensePlatform = sensePlatform;
		SubscriptionManager sm = SubscriptionManager.getInstance();
		// Check if the DataProcessor is already registered at the Sense Service 
		if(sm.isProducerRegistered(FallDetectDemo.TAG))
		{
			// Get the getData class which has the fragment for the display
			getData = (GetData) sm.getSubscribedConsumers(FallDetectDemo.TAG).get(0);
			// Get the FallDetect DataProcessor
			fallDetect = (FallSensor) sm.getRegisteredProducers(FallDetectDemo.TAG).get(0);
		}
		else
		{
			// Create new GetData DataProcessor which is used to display the data on a fragment, and send it to CommonSense
			getData = new GetData(FragmentDisplay.newInstance(TAG));
			// Create the actual FallDetect DataProcessor, which will be registered at the Sense Service with the given name (TAG)
			fallDetect = new FallSensor(TAG, sensePlatform.getService().getSenseService());
			// Subscribe the GetData class to get data from the FallDetect Data Processor 
			sm.subscribeConsumer(TAG, getData);
			// only detect fall when the phone is carried on body
			// Un-comment this to enable fall detect only when the Carry Device Data Processor has detected that the phone is carried on body
			// sensePlatform.getService().getSenseService().subscribeDataProcessor(CarryDeviceDemo.TAG, getData);
			// by default the demo property is disabled
			// When it is enabled a fall will be triggered when a free fall is detected
			// fallDetect.setDemo(false);
			// Use the check for orientation change and inactivity after a free fall followed by an impact. Default is true
			// fallDetect.setUseInactivity(true);			
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
					final String name = "fall detect";
					final String displayName = TAG;
					final String dataType = "json";
					final String description = name;					
					final String value = dataPoint.getJSONValue().getJSONObject("value").toString();
					final long timestamp = dataPoint.timeStamp;
					
					// Add data to the fragment display
					fDisplay.addText(value);

					// Only try to send data when the service is bound
					if(sensePlatform.getService().isBinderAlive())
					{
						try {
							sendData =  new Thread() { public void run() {
								sensePlatform.addDataPoint(name, displayName, description, dataType, value, timestamp); 
							}};
							sendData.start();
						} catch (Exception e) {
							Log.e(TAG, "Failed to add fall detect data point!", e);
						}
					}					
				}
				// Only enable the fall detection when it is carried on body.
				if(dataPoint.sensorName == CarryDeviceDemo.TAG)
				{
					if(dataPoint.getJSONValue().getJSONObject("value").getInt("on body") == 0)
						fallDetect.disable();
					else
						fallDetect.enable();
				}
			}catch(Exception e)
			{
				Log.e(TAG, e.getMessage());
			}
		}
	}
}
