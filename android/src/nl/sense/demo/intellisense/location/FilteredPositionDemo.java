package nl.sense.demo.intellisense.location;

import org.json.JSONObject;

import nl.sense_os.intellisense.dataprocessor.FilteredPosition;
import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.shared.DataProcessor;
import nl.sense_os.service.shared.SensorDataPoint;
import android.util.Log;

public class FilteredPositionDemo {
	private FilteredPosition filteredPosition;
	public final static String TAG = "My Filtered Position Demo";	
	private Thread sendData;
	private SensePlatform sensePlatform;

	public FilteredPositionDemo(SensePlatform sensePlatform)
	{		
		this.sensePlatform = sensePlatform;
		filteredPosition = new FilteredPosition(TAG, sensePlatform.getService().getSenseService());
		filteredPosition.addSubscriber(new GetData());
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
					final String name = "position filter";
					final String displayName = TAG;
					final String dataType = "json";
					final String description = name;					
					JSONObject json = dataPoint.getJSONValue();				
					Log.e(TAG,json.getJSONObject("value").toString());
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
