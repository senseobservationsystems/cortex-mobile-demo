package nl.sense.demo.intellisense.activity;

import org.json.JSONObject;

import android.util.Log;
import nl.sense.demo.FragmentDisplay;
import nl.sense_os.intellisense.dataprocessor.PhysicalActivity;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.shared.DataProcessor;
import nl.sense_os.service.shared.SensorDataPoint;

public class PhysicalActivityDemo {

	private PhysicalActivity physicalActivity;
	public final static String TAG = "My Physical Activity Demo";
	private SensePlatform sensePlatform;
	Thread sendData;
	private GetData getData;

	public PhysicalActivityDemo(SensePlatform sensePlatform)
	{	
		
		this.sensePlatform = sensePlatform;
		if(sensePlatform.getService().getSenseService().isDataProducerRegistered(PhysicalActivityDemo.TAG))
		{
			getData = (GetData) sensePlatform.getService().getSenseService().getSubscribedDataProcessor(PhysicalActivityDemo.TAG).get(0);
			physicalActivity = (PhysicalActivity) sensePlatform.getService().getSenseService().getRegisteredDataProducer(PhysicalActivityDemo.TAG).get(0);
		}
		else
		{
			getData = new GetData(FragmentDisplay.newInstance(TAG));
			physicalActivity = new PhysicalActivity(TAG, sensePlatform.getService().getSenseService());
			sensePlatform.getService().getSenseService().subscribeDataProcessor(TAG, getData);
		}
	}
	
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
					final String name = "physical activity";
					final String displayName = TAG;
					final String dataType = "string";
					final String description = name;
					JSONObject json = dataPoint.getJSONValue();				
					
					// the value to be sent as string
					final String value = json.getString("value");
					fDisplay.addText(value);
					final long timestamp = dataPoint.timeStamp;
					try {
						sendData =  new Thread() { public void run() {
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
