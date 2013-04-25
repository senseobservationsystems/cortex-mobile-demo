package nl.sense.demo;


import java.util.ArrayList;
import java.util.List;

import nl.sense.demo.R;
import nl.sense.demo.intellisense.activity.FallDetectDemo;
import nl.sense.demo.intellisense.activity.PhysicalActivityDemo;
import nl.sense.demo.intellisense.location.FilteredPositionDemo;
import nl.sense.demo.intellisense.location.GeoFenceDemo;
import nl.sense.demo.intellisense.presence.CarryDeviceDemo;

import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.ISenseServiceCallback;
import nl.sense_os.service.SenseService;
import nl.sense_os.service.SenseServiceStub;
import nl.sense_os.service.commonsense.SenseApi;
import nl.sense_os.service.constants.SensePrefs;

import nl.sense_os.service.constants.SensePrefs.Main.Ambience;
import nl.sense_os.service.constants.SensePrefs.Main.Location;
import nl.sense_os.service.constants.SensePrefs.Main.Motion;

import nl.sense_os.service.constants.SensePrefs.Main.PhoneState;

import android.content.ComponentName;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.os.RemoteException;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;

/**
 * Main activity of the Sense Platform Demo. This activity is created to demonstrate the most
 * important use cases of the Sense Platform library in Android. The goal is to provide useful code
 * snippets that you can use in your own Android project.<br/>
 * <br/>
 * The activity has a trivial UI, but automatically performs the following tasks when it is started.
 * <ul>
 * <li>Create a {@link SensePlatform} instance for communication with the Sense service.</li>
 * <li>Log in as user "foo".</li>
 * <li>Set some sensing preferences, e.g. sample rate and sync rate.</li>
 * <li>Start a couple of sensor modules.</li>
 * <li>Send data for a non-standard sensor: "position_annotation".</li>
 * <li>Get data from a certain sensor.</li>
 * </ul>
 * This class implements the {@link ServiceConnection} interface so it can receive callbacks from the
 * SensePlatform object.
 * 
 * UPDATE:
 * This version demonstrates the usage of the IntelliSense package in combination with the Sense Platform library.
 * To obtain the IntelliSense package please contact one of the persons below.  
 * 
 * @author Steven Mulder <steven@sense-os.nl>
 * @author Pim Nijdam <pim@sense-os.nl>
 * @author Ted Schmidt <ted@sense-os.nl>
 */
public class MainActivity extends FragmentActivity implements ServiceConnection {




	/**
	 * Service stub for callbacks from the Sense service.
	 */
	private class SenseCallback extends ISenseServiceCallback.Stub {
		@Override
		public void onChangeLoginResult(int result) throws RemoteException {
			switch (result) {
			case 0:
				Log.v(TAG, "Change login OK");
				onLoggedIn();
				break;
			case -1:
				Log.v(TAG, "Login failed! Connectivity problems?");
				break;
			case -2:
				Log.v(TAG, "Login failed! Invalid username or password.");
				break;
			default:
				Log.w(TAG, "Unexpected login result! Unexpected result: " + result);
			}
		}

		@Override
		public void onRegisterResult(int result) throws RemoteException {
			// not used
		}

		@Override
		public void statusReport(final int status) {
			// not used
		}
	}

	private static final String TAG = "Sense Demo";

	private SensePlatform sensePlatform = null;
	private SenseCallback callback = new SenseCallback();
	private FilteredPositionDemo filteredPositionDemo = null;	
	private GeoFenceDemo geoFenceDemo = null;
	private PhysicalActivityDemo physicalActivityDemo = null;
	private CarryDeviceDemo carryDeviceDemo = null;	
	private FallDetectDemo fallDetectDemo = null;
	private MyPageAdapter pageAdapter;		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// trivial UI
		setContentView(R.layout.activity_main);		 

	}


	private List<Fragment> getFragments(){
		List<Fragment> fList = new ArrayList<Fragment>();

		fList.add(FragmentDisplay.newInstance("Fragment 1"));
		fList.add(FragmentDisplay.newInstance("Fragment 2")); 
		fList.add(FragmentDisplay.newInstance("Fragment 3"));

		return fList;
	}



	class MyPageAdapter extends FragmentPagerAdapter {
		private List<Fragment> fragments;

		public MyPageAdapter(FragmentManager fm, List<Fragment> fragments) {
			super(fm);
			this.fragments = fragments;
		}
		@Override 
		public Fragment getItem(int position) {
			return this.fragments.get(position);
		}

		@Override
		public int getCount() {
			return this.fragments.size();
		}
	}


	@Override
	protected void onDestroy() {
		// close binding with the Sense service
		// (the service will remain running on its own if it is not explicitly stopped!)
		//sensePlatform.close();
		super.onDestroy();
	}

	/**
	 * Callback for when the service logged in, gets called from the SenseCallback object.<br/>
	 * <br/>
	 * Starts sensing, and sends and gets some data. It is recommended to wait until the login has
	 * finished before actually starting the sensing.
	 */
	private void onLoggedIn() {
		try {


		} catch (Exception e) {
			Log.e(TAG, "Exception while starting sense library.", e);
		}
	}

	@Override
	public void onServiceConnected(ComponentName name, IBinder service) {
		// set up the sense service as soon as we are connected to it
		setupSense();
	}

	@Override
	public void onServiceDisconnected(ComponentName className) {
		// not used
	}

	@Override
	protected void onStart() {
		Log.v(TAG, "onStart");
		super.onStart();

		// create SensePlatform instance to do the complicated work
		// (when the service is ready, we get a call to onServiceConnected)
		if(sensePlatform == null)
			sensePlatform = new SensePlatform(this, this);		
	}


	/**
	 * Sets up the Sense service preferences and logs in
	 */
	private void setupSense() {
		try {
			SenseServiceStub service = sensePlatform.getService();
			SenseService senseService = service.getSenseService();

			// Create the Demo DataProcessors with the bound senseService			
			if(filteredPositionDemo == null && !senseService.isDataProducerRegistered(FilteredPositionDemo.TAG))			
				filteredPositionDemo = new FilteredPositionDemo(sensePlatform);		
			
			if(geoFenceDemo == null && !senseService.isDataProducerRegistered(GeoFenceDemo.TAG))			
				geoFenceDemo = new GeoFenceDemo(sensePlatform); 
			
			if(physicalActivityDemo == null)	
				physicalActivityDemo = new PhysicalActivityDemo(sensePlatform);
			
			if(carryDeviceDemo == null && !senseService.isDataProducerRegistered(CarryDeviceDemo.TAG))			
				carryDeviceDemo = new CarryDeviceDemo(sensePlatform);			

			if(fallDetectDemo == null)			
				fallDetectDemo = new FallDetectDemo(sensePlatform);		

			// set the view			
			List<Fragment> fragments = new ArrayList<Fragment>();
			fragments.add(fallDetectDemo.getFragment());
			fragments.add(physicalActivityDemo.getFragment());			
			pageAdapter = new MyPageAdapter(getSupportFragmentManager(), fragments);
			ViewPager pager =  (ViewPager)findViewById(R.id.viewpager);
			pager.setAdapter(pageAdapter);
			// log in (you only need to do this once, Sense will remember the login)
			sensePlatform.login("foo", SenseApi.hashPassword("bar"), callback);
			// this is an asynchronous call, we get a call to the callback object when the login is complete

			// turn on specific sensors			
			//  settings for the Geo-Fencing demo
			service.setPrefBool(Location.GPS, true);
			service.setPrefBool(Location.NETWORK, true);
			service.setPrefBool(Location.AUTO_GPS, true);

			// settings for the carry device demo
			service.setPrefBool(PhoneState.CALL_STATE, true);
			service.setPrefBool(PhoneState.PROXIMITY, true);
			service.setPrefBool(PhoneState.SCREEN_ACTIVITY, true);
			service.setPrefBool(Ambience.LIGHT, true);
			service.setPrefBool(Ambience.AUDIO_SPECTRUM, false);
			service.setPrefBool(Ambience.MAGNETIC_FIELD, false);
			service.setPrefBool(Ambience.MIC, false);

			// settings for physical activity demo and fall detect 
			// TODO: create separate preference for the new fall detector 
			service.setPrefBool(Motion.BURSTMODE, true);

			// set how often to sample
			// 1 := rarely (~every 15 min)
			// 0 := normal`  (~every 5 min)
			// -1 := often (~every 10 sec)
			// -2 := real time (this setting affects power consumption considerably!)
			service.setPrefString(SensePrefs.Main.SAMPLE_RATE, "0");

			// set how often to upload
			// 1 := eco mode (buffer data for 30 minutes before bulk uploading)
			// 0 := normal (buffer 5 min)
			// -1 := often (buffer 1 min)
			// -2 := real time (every new data point is uploaded immediately)
			service.setPrefString(SensePrefs.Main.SYNC_RATE, "0");


			service.toggleMain(true);
			// carry device
			service.toggleAmbience(true);
			// carry device, physical activity
			service.toggleMotion(true);
			// carry device
			service.togglePhoneState(true);
			// geo-fencing
			service.toggleLocation(true);

		} catch (Exception e) {
			Log.e(TAG, "Exception while setting up Sense library.", e);
		}
	}	

}
