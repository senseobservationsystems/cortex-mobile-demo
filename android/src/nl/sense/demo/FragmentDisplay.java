package nl.sense.demo;


import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Iterator;
import java.util.SortedSet;
import java.util.TreeSet;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import android.widget.TableRow.LayoutParams;
import android.widget.HorizontalScrollView;
import android.widget.ScrollView;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

public class FragmentDisplay extends Fragment 
{
	public static final String TITLE = "TITLE";	
	public JSONArray output = new JSONArray();
	public View v = null;
	private float mx, my;
    private float curX, curY;

    private ScrollView vScroll;
    private HorizontalScrollView hScroll;

	public static final FragmentDisplay newInstance(String message)
	{
		FragmentDisplay f = new FragmentDisplay();
		Bundle bdl = new Bundle(1);
		bdl.putString(TITLE, message);
		f.setArguments(bdl);	     
		return f;
	}

	public void addText(final String message)
	{
		Calendar cal = Calendar.getInstance();
		cal.getTime();
		SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
		System.out.println( sdf.format(cal.getTime()) );
		JSONObject data = null;
		try {
			data = new JSONObject(message);
		} catch (JSONException e) {
			data = new JSONObject();
			try {
				data.put("value", message);
			} catch (JSONException e1) { e1.printStackTrace();}
		}

		try {
			data.put("time", sdf.format(cal.getTime()));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		output.put(data);	
		final JSONObject d = data;		
		Handler h = new Handler(Looper.getMainLooper());
		h.post(new Runnable() {			
			@Override
			public void run() {
				if(v == null)
					return;				
				addRow(d);
			}
		});
	}

	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) 
	{
		String message = getArguments().getString(TITLE);		
		this.v = inflater.inflate(R.layout.fragmentdisplay_layout, container, false);
		 vScroll = (ScrollView) v.findViewById(R.id.vScroll);
	        hScroll = (HorizontalScrollView) v.findViewById(R.id.hScroll); 
		final GestureDetector gesture = new GestureDetector(getActivity(),
	            new GestureDetector.SimpleOnGestureListener() {

	                @Override
	                public boolean onDown(MotionEvent e) {
	                    return true;
	                }

	                @Override
	                public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
	                    float velocityY) {
	                   
	                    return super.onFling(e1, e2, velocityX, velocityY);
	                }
	            });

		
	        v.setOnTouchListener(new View.OnTouchListener() {
	            @Override
	            public boolean onTouch(View v, MotionEvent event) {
	            	 float curX, curY;	            	 
	                 switch (event.getAction()) {

	                     case MotionEvent.ACTION_DOWN:
	                         mx = event.getX();
	                         my = event.getY();
	                         break;
	                     case MotionEvent.ACTION_MOVE:
	                         curX = event.getX();
	                         curY = event.getY();
	                         vScroll.scrollBy((int) (mx - curX), (int) (my - curY));
	                         hScroll.scrollBy((int) (mx - curX), (int) (my - curY));
	                         mx = curX;
	                         my = curY;
	                         break;
	                     case MotionEvent.ACTION_UP:
	                         curX = event.getX();
	                         curY = event.getY();
	                         vScroll.scrollBy((int) (mx - curX), (int) (my - curY));
	                         hScroll.scrollBy((int) (mx - curX), (int) (my - curY));
	                         break;
	                 }

	                 return true;
	            }
	        });
		
		
		TextView messageTextView = (TextView)v.findViewById(R.id.textView);
		messageTextView.setText(message);	
		TableLayout tl = (TableLayout)v.findViewById(R.id.tableLayoutOutput);		
		tl.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT));
		for(int i = 0; i < output.length(); i++)
		{
			try {
				JSONObject json = output.getJSONObject(i);				
				addRow(json);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return v;
	}


 
	private void addRow(JSONObject message)
	{
		try
		{
			if(v == null)
				return;
			TableLayout tl = (TableLayout)v.findViewById(R.id.tableLayoutOutput);		
			tl.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.MATCH_PARENT));		
			boolean createHeader = (tl.getChildCount() == 0);						
			TableRow tr = new TableRow(getActivity());			
			TextView date = new TextView(getActivity());
			createView(tr, date,createHeader?"time":message.getString("time"));

			Iterator<?> keys = message.keys();
			SortedSet<String> header = new TreeSet<String>();
			while(keys.hasNext())
			{				
				String key = (String)keys.next();
				header.add(key);
			}
			keys = header.iterator();
			while(keys.hasNext())
			{
				String key = (String)keys.next();
				if(key.equals("time"))
					continue;
				TextView tv1 = new TextView(getActivity());
				if(message.optJSONObject(key) != null)
					addRow(message.optJSONObject(key));
				else 
					createView(tr, tv1,createHeader?key:message.getString(key));
			}	
			// skip the header but put on top
			if(tl.getChildCount() > 0)
				tl.addView(tr, 1);
			else
			{
				tl.addView(tr);
				addRow(message);
			}

		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}

	@SuppressLint("NewApi")
	public void createView(TableRow tr, TextView t, String viewdata) {
		t.setText(viewdata);
		//adjust the properties of the textView
		t.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.MATCH_PARENT));
		t.setTextColor(Color.BLACK);
		t.setTextSize(10);
		t.setBackgroundColor(Color.WHITE);
		t.setPadding(10, 1, 1, 1);
		tr.setPadding(1, 1, 1, 1);
		tr.setBackgroundColor(Color.BLACK);
		tr.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.MATCH_PARENT));
		tr.addView(t); // add TextView to row.
	}
}
