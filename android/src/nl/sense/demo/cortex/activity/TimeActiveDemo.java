package nl.sense.demo.cortex.activity;

import org.json.JSONObject;

import android.util.Log;
import nl.sense.demo.FragmentDisplay;
import nl.sense_os.cortex.TimeActiveSensor;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.subscription.*;
import nl.sense_os.service.shared.SensorDataPoint;
import nl.sense_os.service.subscription.DataConsumer;

public class TimeActiveDemo {
	
	//The name of the DataProcessor
	private static String TAG = "My TimeActive Demo";

	// The DataProcessor which handles the data coming from the PhysicalActivity DataProcessor
	private GetData getData;
	Thread sendData;

	public TimeActiveDemo(SensePlatform sensePlatform)
	{
		SubscriptionManager sm = SubscriptionManager.getInstance();
		// Check if the DataProcessor is already registered at the Sense Service
		if(sm.isProducerRegistered(TimeActiveDemo.TAG))
		{
			// Get the getData class which has the fragment for the display
			getData = (GetData) sm.getSubscribedConsumers(TimeActiveDemo.TAG).get(0);			
		}
		else
		{
			// Create new GetData DataProcessor which is used to display the data on a fragment, and send it to CommonSense
			getData = new GetData(FragmentDisplay.newInstance(TAG));
			// Create the actual TimeActive DataProcessor, which will be registered at the Sense Service with the given name (TAG)
			TimeActiveSensor ta = new TimeActiveSensor(TAG, sensePlatform);
			ta.setVerbose(true);
			//reset every day at 00:00
			//Calendar resetDate = new GregorianCalendar(2013, 1, 1, 0, 0, 0);
			//ta.setPeriodicReset(resetDate, TimeActiveSensor.PERIOD_MINUTE);
			//ta.clearPeriodicReset();
			// Subscribe the GetData class to get data from the TimeActiveDemo Data Processor
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
					JSONObject json = dataPoint.getJSONValue();				
					// the value to be sent as string
					final String value = json.getString("value");
					
					// Add data to the fragment display
					fDisplay.addText(value);
				}
			}catch(Exception e)
			{
				Log.e(TAG, e.getMessage());
			}
		}
	}
}