package com.example.fluttermap;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.MenuItem;

import com.amap.api.maps2d.AMap;
import com.amap.api.maps2d.MapView;
import com.amap.api.maps2d.model.LatLng;
import com.amap.api.maps2d.model.MarkerOptions;
import com.amap.api.maps2d.model.MyLocationStyle;

public class MapActivity extends AppCompatActivity {

    MapView mapView;
    private AMap map;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_map);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        mapView = findViewById(R.id.map);

        mapView.onCreate(savedInstanceState);
        if (map == null) {
            map = mapView.getMap();
        }
        MyLocationStyle locationStyle = new MyLocationStyle();
        locationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATE);
        locationStyle.interval(2000);
        map.setMyLocationStyle(locationStyle);
//        map.getUiSettings().setMyLocationButtonEnabled(true);
        map.setMyLocationEnabled(true);
        double Lat = getIntent().getDoubleExtra("Lat", 0);
        double Lng = getIntent().getDoubleExtra("Lng", 0);
        if (Lat != 0d && Lng != 0d) {
            LatLng latLng = new LatLng(Lat, Lng);
            String title = "";
            if (!TextUtils.isEmpty(getIntent().getStringExtra("Addr"))) {
                map.addMarker(new MarkerOptions().position(latLng).title(getIntent().getStringExtra("Addr")).draggable(false));
                return;
            }
            if (!TextUtils.isEmpty(getIntent().getStringExtra("Nnm"))) {
                map.addMarker(new MarkerOptions().position(latLng).title(getIntent().getStringExtra("Nnm")).draggable(false));
                return;
            }
            if (!TextUtils.isEmpty(getIntent().getStringExtra("Re"))) {
                map.addMarker(new MarkerOptions().position(latLng).title(getIntent().getStringExtra("Re")).draggable(false));
                return;
            }
            if (!TextUtils.isEmpty(getIntent().getStringExtra("CDNO"))) {
                map.addMarker(new MarkerOptions().position(latLng).title(getIntent().getStringExtra("CDNO")).draggable(false));
                return;
            }
        }

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                finish();
                break;
        }
        return super.onOptionsItemSelected(item);
    }

    protected void onDestroy() {
        super.onDestroy();
        mapView.onDestroy();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mapView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mapView.onPause();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        mapView.onSaveInstanceState(outState);
    }

}
