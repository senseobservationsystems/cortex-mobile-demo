package nl.sense.demo.cortex.location;

import nl.sense.demo.FragmentDisplay;
import nl.sense_os.cortex.LocationTraceSensor;
import nl.sense_os.cortex.module.sensors.Sensors;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.shared.SensorDataPoint;
import nl.sense_os.service.subscription.DataConsumer;
import nl.sense_os.service.subscription.SubscriptionManager;

import org.json.JSONObject;

import android.util.Log;

public class LocationTraceDemo {	
	
	/** The DataProcessor */
	private LocationTraceSensor locationTrace;

	/** The name of the DataProcessor */
	private static String TAG = "My Location Trace Demo";
	/** Connection to the SenseService **/
	private SensePlatform sensePlatform;

	/** The DataProcessor which handles the data coming from the TimeTraveled DataProcessor */
	private GetData getData;
	private Thread sendData;

	public LocationTraceDemo(SensePlatform sensePlatform)
	{		
		this.sensePlatform = sensePlatform;
		SubscriptionManager sm = SubscriptionManager.getInstance();
		// Check if the DataProcessor is already registered at the Sense Service
		if(sm.isProducerRegistered(LocationTraceDemo.TAG))
		{
			// Get the getData class which has the fragment for the display
			getData = (GetData) sm.getSubscribedConsumers(LocationTraceDemo.TAG).get(0);			
			
			//timeTraveled = (TimeTraveledSensor) sm.getRegisteredProducers(TimeTraveledDemo.TAG).get(0);

		}
		else
		{
			// Create new GetData DataProcessor which is used to display the data on a fragment, and send it to CommonSense
			getData = new GetData(FragmentDisplay.newInstance(TAG));
			// Create the actual TimeTraveled DataProcessor, which will be registered at the Sense Service with the given name (TAG)
			locationTrace =	new LocationTraceSensor(TAG, sensePlatform);
			// Subscribe the GetData class to get data from the FallDetect Data Processor
			sm.subscribeConsumer(TAG, getData);
			
			
			sm.subscribeConsumer(Sensors.getSENSOR_POSITION(),getData);

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
					
					Log.e(TAG, "New Location");
					
					// Description of the sensor
					// This is only used to send data to CommonSense
					final String name = "time traveled";
					final String displayName = TAG;
					final String dataType = "json";
					final String description = name;					
					JSONObject json = dataPoint.getJSONValue();				
					
					
					// the value to be sent, in json format
					final String value = json.getJSONObject("value").getString("event");
					
					//System.out.println(json.getJSONObject("value").getString("event"));
					
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
				else if(dataPoint.sensorName.equals(Sensors.getSENSOR_POSITION())){
					
					
					JSONObject json = dataPoint.getJSONValue();				

					System.out.println(json.getString("value"));
					
				}
			}catch(Exception e)
			{
				Log.e(TAG, e.getMessage());
			}		
		}		
	}
}
