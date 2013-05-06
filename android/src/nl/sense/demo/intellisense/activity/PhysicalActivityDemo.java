package nl.sense.demo.intellisense.activity;

import org.json.JSONObject;

import android.util.Log;
import nl.sense.demo.FragmentDisplay;
import nl.sense_os.intellisense.dataprocessor.PhysicalActivity;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.shared.DataProcessor;
import nl.sense_os.service.shared.SensorDataPoint;

public class PhysicalActivityDemo {
	public final static String TAG = "My Physical Activity Demo";
	private SensePlatform sensePlatform;
	Thread sendData;
	private GetData getData;

	public PhysicalActivityDemo(SensePlatform sensePlatform)
	{	

		this.sensePlatform = sensePlatform;
		// Check if the DataProcessor is already registered at the Sense Service
		if(sensePlatform.getService().getSenseService().isDataProducerRegistered(PhysicalActivityDemo.TAG))
		{
			// Get the getData class which has the fragment for the display
			getData = (GetData) sensePlatform.getService().getSenseService().getSubscribedDataProcessor(PhysicalActivityDemo.TAG).get(0);			
		}
		else
		{
			// Create new GetData DataProcessor which is used to display the data on a fragment, and send it to CommonSense
			getData = new GetData(FragmentDisplay.newInstance(TAG));
			new PhysicalActivity(TAG, sensePlatform.getService().getSenseService());
			sensePlatform.getService().getSenseService().subscribeDataProcessor(TAG, getData);
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
					final String name = "physical activity";
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
