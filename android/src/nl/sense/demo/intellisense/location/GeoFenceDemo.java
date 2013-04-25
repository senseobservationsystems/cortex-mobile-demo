package nl.sense.demo.intellisense.location;

import org.json.JSONObject;

import android.util.Log;
import nl.sense_os.intellisense.dataprocessor.GeoFence;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.shared.DataProcessor;
import nl.sense_os.service.shared.SensorDataPoint;

public class GeoFenceDemo {

	private GeoFence geoFence;
	public final static String TAG = "My Geo-Fencing Demo";
	private SensePlatform sensePlatform;
	private Thread sendData;

	public GeoFenceDemo(SensePlatform sensePlatform)
	{		
		this.sensePlatform = sensePlatform;
		geoFence = new GeoFence(TAG, sensePlatform.getService().getSenseService());	
		geoFence.setGoalLocation(53.20987,6.54536);
		geoFence.setRange(100);
		geoFence.addSubscriber(new GetData());
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
					final String name = "geo-fence";
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
