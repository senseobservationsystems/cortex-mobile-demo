package nl.sense.demo;

import java.util.ArrayList;
import java.util.List;

import nl.sense.demo.R;
import nl.sense.demo.cortex.activity.FallDetectDemo;
import nl.sense.demo.cortex.activity.PhysicalActivityDemo;
import nl.sense.demo.cortex.activity.SitStandDemo;
import nl.sense.demo.cortex.location.FilteredPositionDemo;
import nl.sense.demo.cortex.location.GeoFenceDemo;
import nl.sense.demo.cortex.presence.CarryDeviceDemo;

import nl.sense_os.platform.SensePlatform;
import nl.sense_os.service.ISenseServiceCallback;
import nl.sense_os.service.SenseServiceStub;
import nl.sense_os.service.commonsense.SenseApi;
import nl.sense_os.service.constants.SensePrefs;
import nl.sense_os.service.constants.SenseStatusCodes;

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
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;

/**
 * Main activity of the Sense Cortex Demo. This activity is created to demonstrate the most
 * important use cases of the Sense Cortex library in Android. The goal is to provide useful code
 * snippets that you can use in your own Android project.<br/>
 * <br/>
 * The activity performs the following tasks when it is started.
 * <ul>
 * <li>Create a {@link SensePlatform} instance for communication with the Sense service.</li>
 * <li>Log in as user "cortex".</li>
 * <li>Set some sensing preferences, e.g. sample rate and sync rate.</li>
 * <li>Start a couple of Data Processors.</li> * 
 * <li>Display and upload data comming from the data processors</li>
 * </ul>
 * This class implements the {@link ServiceConnection} interface so it can receive callbacks from the
 * SensePlatform object.
 *
 * To use this demo application you need the cortex library files. 
 * To obtain the cortex library please contact one of the persons below.  
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

			// set up the sense service as soon as we are connected 
			if((status & SenseStatusCodes.RUNNING) <= 0) 
				setupSense();
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
	private SitStandDemo sitStandDemo = null;
	private MyPageAdapter pageAdapterActivity;
	private MyPageAdapter pageAdapterLocation;	
	private MyPageAdapter pageAdapterPresence;	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Log.e(TAG, "Create");
		// trivial UI
		setContentView(R.layout.activity_main);
	}

	/**
	 * A page adapter to hold the fragments of the categories
	 * 
	 */
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
		// (the service will remain running on its own if it is not explicitly stopped!)
		super.onDestroy();			
	}

	@Override
	public void onServiceConnected(ComponentName name, IBinder service) {

		// Create the Demo DataProcessors with the bound senseService
		if(filteredPositionDemo == null)			
			filteredPositionDemo = new FilteredPositionDemo(sensePlatform);		

		if(geoFenceDemo == null)			
			geoFenceDemo = new GeoFenceDemo(sensePlatform); 

		if(physicalActivityDemo == null)	
			physicalActivityDemo = new PhysicalActivityDemo(sensePlatform);

		if(carryDeviceDemo == null)			
			carryDeviceDemo = new CarryDeviceDemo(sensePlatform);			

		if(fallDetectDemo == null)			
			fallDetectDemo = new FallDetectDemo(sensePlatform);		
		
		if(sitStandDemo == null)			
			sitStandDemo = new SitStandDemo(sensePlatform);

		// Add the activity Fragments to the right pager	
		List<Fragment> fragmentsActivity = new ArrayList<Fragment>();		
		fragmentsActivity.add(physicalActivityDemo.getFragment());	
		fragmentsActivity.add(fallDetectDemo.getFragment());
		fragmentsActivity.add(sitStandDemo.getFragment());		
		setFragmentPager(fragmentsActivity);
		pageAdapterActivity = new MyPageAdapter(getSupportFragmentManager(), fragmentsActivity);
		ViewPager pager =  (ViewPager)findViewById(R.id.viewpagerActivity);
		pager.setAdapter(pageAdapterActivity);

		// Add the location Fragments to the right pager
		List<Fragment> fragmentsLocation = new ArrayList<Fragment>();		
		fragmentsLocation.add(filteredPositionDemo.getFragment());
		fragmentsLocation.add(geoFenceDemo.getFragment());	
		setFragmentPager(fragmentsLocation);		
		pageAdapterLocation = new MyPageAdapter(getSupportFragmentManager(), fragmentsLocation);
		pager =  (ViewPager)findViewById(R.id.ViewPagerLocation);
		pager.setAdapter(pageAdapterLocation);

		// Add the presence Fragments to the right pager
		List<Fragment> fragmentsPresence = new ArrayList<Fragment>();
		fragmentsPresence.add(carryDeviceDemo.getFragment());
		setFragmentPager(fragmentsPresence);
		pageAdapterPresence = new MyPageAdapter(getSupportFragmentManager(), fragmentsPresence);
		pager =  (ViewPager)findViewById(R.id.ViewPagerPresence);
		pager.setAdapter(pageAdapterPresence);

		// Init the Tabs
		TabHost tabHost=(TabHost)findViewById(R.id.tabHost);
		tabHost.setup();
		
		TabSpec spec1= tabHost.newTabSpec("Activity");		
		spec1.setContent(R.id.tabActivity);
		spec1.setIndicator("Activity");
		
		TabSpec spec2=tabHost.newTabSpec("Location");		
		spec2.setContent(R.id.tabLocation);
		spec2.setIndicator("Location");

		TabSpec spec3=tabHost.newTabSpec("Presence");
		spec3.setContent(R.id.tabPresence);
		spec3.setIndicator("Presence");
		tabHost.addTab(spec1);
		tabHost.addTab(spec2);
		tabHost.addTab(spec3);

		try {
			// Check the status of the service
			sensePlatform.getService().getStatus(callback);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * Add pager text to a fragment
	 * @param fragments
	 */
	private void setFragmentPager(List<Fragment> fragments)
	{
		for (int i = 0; i < fragments.size(); i++) 
		{
			String previous = (i == 0)? "" : " < ";
			String next = (i+1 == fragments.size())? "" : " > ";
			((FragmentDisplay)fragments.get(i)).setPager(previous+(i+1)+"/"+fragments.size()+next);
		}
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

			// log in (you only need to do this once, Sense will remember the login)
			sensePlatform.login("cortex", SenseApi.hashPassword("demo"), callback);
			// this is an asynchronous call, we get a call to the callback object when the login is complete

			// turn on specific sensors			
			// settings for the Geo-Fencing demo
			service.setPrefBool(Location.GPS, true);
			service.setPrefBool(Location.NETWORK, true);
			service.setPrefBool(Location.AUTO_GPS, true);

			// settings for the carry device demo
			service.setPrefBool(PhoneState.CALL_STATE, true);
			service.setPrefBool(PhoneState.PROXIMITY, true);
			service.setPrefBool(PhoneState.SCREEN_ACTIVITY, true);
			service.setPrefBool(PhoneState.BATTERY, true);
			service.setPrefBool(Ambience.LIGHT, true);
			service.setPrefBool(Ambience.CAMERA_LIGHT, true);
			service.setPrefBool(Ambience.AUDIO_SPECTRUM, false);
			service.setPrefBool(Ambience.MAGNETIC_FIELD, false);
			service.setPrefBool(Ambience.MIC, false);
			

			// settings for physical activity demo and fall detect 
			// TODO: create separate preference for the new fall detector
			service.setPrefBool(Motion.FALL_DETECT, true);
			service.setPrefBool(Motion.BURSTMODE, true);
			service.setPrefBool(Motion.ACCELEROMETER, true);
			service.setPrefBool(Motion.GYROSCOPE, true);
			service.setPrefBool(Motion.ORIENTATION, false);
			service.setPrefBool(Motion.LINEAR_ACCELERATION, true);

			// set how often to sample
			// 1 := rarely (~every 15 min)
			// 0 := normal`  (~every 5 min)
			// -1 := often (~every 10 sec)
			// -2 := real time (this setting affects power consumption considerably!)
			service.setPrefString(SensePrefs.Main.SAMPLE_RATE, "-1");

			// set how often to upload
			// 1 := eco mode (buffer data for 30 minutes before bulk uploading)
			// 0 := normal (buffer 5 min)
			// -1 := often (buffer 1 min)
			// -2 := real time (every new data point is uploaded immediately)
			service.setPrefString(SensePrefs.Main.SYNC_RATE, "1");

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
