package nl.sense.demo.intellisense.activity;

import android.util.Log;
import nl.sense.demo.FragmentDisplay;
import nl.sense.demo.intellisense.presence.CarryDeviceDemo;
import nl.sense_os.intellisense.dataprocessor.FallDetect;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.shared.DataProcessor;
import nl.sense_os.service.shared.SensorDataPoint;

public class FallDetectDemo {

	private FallDetect fallDetect;
	private static String TAG = "My Fall Detect Demo";
	private SensePlatform sensePlatform;
	
	private GetData getData;
	Thread sendData;

	public FallDetectDemo(SensePlatform sensePlatform)
	{		
		this.sensePlatform = sensePlatform;
		if(sensePlatform.getService().getSenseService().isDataProducerRegistered(FallDetectDemo.TAG))
		{
			getData = (GetData) sensePlatform.getService().getSenseService().getSubscribedDataProcessor(FallDetectDemo.TAG).get(0);
			fallDetect = (FallDetect) sensePlatform.getService().getSenseService().getRegisteredDataProducer(FallDetectDemo.TAG).get(0);
		}
		else
		{
			getData = new GetData(FragmentDisplay.newInstance(TAG));
			fallDetect = new FallDetect(TAG, sensePlatform.getService().getSenseService());	
			sensePlatform.getService().getSenseService().subscribeDataProcessor(TAG, getData);
			// only detect fall when the phone is in the pocket
			sensePlatform.getService().getSenseService().subscribeDataProcessor(CarryDeviceDemo.TAG, getData);
			// by default the demo property is disabled
			fallDetect.setDemo(false);
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
					final String name = "fall detect";
					final String displayName = TAG;
					final String dataType = "json";
					final String description = name;					
					final String value = dataPoint.getJSONValue().getJSONObject("value").toString();
					final long timestamp = dataPoint.timeStamp;
					fDisplay.addText(value);
					
					try {
						sendData =  new Thread() { public void run() {
							 sensePlatform.addDataPoint(name, displayName, description, dataType, value, timestamp); 
						 }};
						 sendData.start();
					} catch (Exception e) {
						Log.e(TAG, "Failed to add fall detect data point!", e);
					}
				}
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
