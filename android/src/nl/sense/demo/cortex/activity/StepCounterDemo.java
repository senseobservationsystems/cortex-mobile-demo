package nl.sense.demo.cortex.activity;

import org.json.JSONObject;

import android.util.Log;
import nl.sense.demo.FragmentDisplay;
import nl.sense_os.cortex.StepCountSensor;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.subscription.*;
import nl.sense_os.service.shared.SensorDataPoint;

public class StepCounterDemo {
	
	/** The name of the DataProcessor */
	private static String TAG = "My StepCounter Demo";
	/** Connection to the SenseService **/
	private SensePlatform sensePlatform;

	/** The DataProcessor which handles the data coming from the PhysicalActivity DataProcessor */
	private GetData getData;
	Thread sendData;

	public StepCounterDemo(SensePlatform sensePlatform)
	{	
		this.sensePlatform = sensePlatform;
		SubscriptionManager sm = SubscriptionManager.getInstance();
		// Check if the DataProcessor is already registered at the Sense Service
		if(sm.isProducerRegistered(StepCounterDemo.TAG))
		{
			// Get the getData class which has the fragment for the display
			getData = (GetData) sm.getSubscribedConsumers(StepCounterDemo.TAG).get(0);			
		}
		else
		{
			// Create new GetData DataProcessor which is used to display the data on a fragment, and send it to CommonSense
			getData = new GetData(FragmentDisplay.newInstance(TAG));
			// Create the actual PhysicalActivity DataProcessor, which will be registered at the Sense Service with the given name (TAG)
			new StepCountSensor(TAG, sensePlatform);
			// Subscribe the GetData class to get data from the FallDetect Data Processor
			sm.subscribeConsumer(TAG, getData);
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
					final String name = "step counter";
					final String displayName = TAG;
					final String dataType = "string";
					final String description = name;
					JSONObject json = dataPoint.getJSONValue();				

					// the value to be sent as string
					final String value = json.getString("value");
					
					// Add data to the fragment display
					fDisplay.addText(value);
					final long timestamp = dataPoint.timeStamp;

					// Only try to send data when the service is bound
					if(sensePlatform.getService().isBinderAlive())
					{
						try {
							sendData =  new Thread() { public void run() {
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
