package com.example.fluttermap;


import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.yanzhenjie.permission.Action;
import com.yanzhenjie.permission.AndPermission;
import com.yanzhenjie.permission.Permission;
import com.yanzhenjie.permission.Rationale;
import com.yanzhenjie.permission.RequestExecutor;
import com.yanzhenjie.permission.SettingService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FluttermapPlugin
 */
public class FluttermapPlugin implements MethodCallHandler , AMapLocationListener {

  private static Activity mActivity;

  private AMapLocationClient mLocationClient = null;
  //声明AMapLocationClientOption对象
  private AMapLocationClientOption mLocationOption = null;

  private Result mResult;

  private AMapLocation mAMapLocation;

  private Handler mHandler = new Handler(){
    @Override
    public void handleMessage(Message msg) {
      super.handleMessage(msg);
      switch (msg.what){
        case 1:
          if(mResult == null) return;
          Map<String, Object> data = new HashMap<>();
          data.put("error", "定位超时");
          mResult.success(data);
          mResult = null;
          break;
      }
    }
  };

  private Rationale mRationale = new Rationale() {
    @Override
    public void showRationale(Context context, List<String> permissions,
                              final RequestExecutor executor) {
      // 这里使用一个Dialog询问用户是否继续授权。
      new AlertDialog.Builder(mActivity)
              .setMessage("需要定位权限才能获取当前位置, 是否继续授权")
              .setOnCancelListener(new DialogInterface.OnCancelListener() {
                @Override
                public void onCancel(DialogInterface dialog) {
                  // 如果用户不同意去设置：
                  executor.cancel();
                }
              })
              .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                  // 如果用户同意去设置：
                  executor.execute();
                }
              })
              .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                  executor.cancel();

                }
              });
    }
  };

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "hdkj/fluttermap");
    mActivity = registrar.activity();
    channel.setMethodCallHandler(new FluttermapPlugin());
  }

  private void startLocation(){
    Log.d("flutter", "开始定位...");

    if(mLocationClient == null){
      //初始化定位
      mLocationClient = new AMapLocationClient(mActivity);
      //设置定位回调监听
      mLocationClient.setLocationListener(this);
      AMapLocationClientOption option = new AMapLocationClientOption();
      /**
       * 设置定位场景，目前支持三种场景（签到、出行、运动，默认无场景）
       */
//      option.setLocationPurpose(AMapLocationClientOption.AMapLocationPurpose.SignIn);
      mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Battery_Saving);
//      mLocationOption.setOnceLocation(true);
      mLocationOption.setNeedAddress(true);
      mLocationOption.setInterval(2000);
//      mLocationOption.setOnceLocationLatest(true);
      mLocationClient.setLocationOption(option);
      //设置场景模式后最好调用一次stop，再调用start以保证场景模式生效
      mLocationClient.stopLocation();
    }


    mLocationClient.startLocation();
    mLocationClient.getLastKnownLocation();

  }

  private  void returnResult(Result result){
    Map<String, Object> data = new HashMap<>();
    data.put("lat", mAMapLocation.getLatitude());
    data.put("lng", mAMapLocation.getLongitude());
    data.put("address", mAMapLocation.getAddress());
    if(result == null && mResult != null){
      mResult.success(data);
      mResult = null;
    } if(result != null){
      result.success(data);
    }
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if(call.method.equals("getLocation")){
      if(mAMapLocation != null){
        returnResult(result);
        return;
      }
      AndPermission.with(mActivity)
              .permission(
                      Permission.ACCESS_COARSE_LOCATION,
                      Permission.ACCESS_FINE_LOCATION,
                      Permission.WRITE_EXTERNAL_STORAGE)
              .onGranted(
                      new Action() {
                        @Override
                        public void onAction(List<String> permissions) {
                          mResult = result;
                          startLocation();

                          mHandler.sendEmptyMessageAtTime(1, 10*1000);
                        }
                      })
              .rationale(mRationale)
              .onDenied(
                      new Action() {
                        @Override
                        public void onAction(List<String> permissions) {
                          if (AndPermission.hasAlwaysDeniedPermission(mActivity, permissions)) {
                            // 这里使用一个Dialog展示没有这些权限应用程序无法继续运行，询问用户是否去设置中授权。

                            final SettingService settingService = AndPermission.permissionSetting(mActivity);

                            new AlertDialog.Builder(mActivity)
                                    .setMessage("需要定位权限才能获取当前位置, 是否进行权限设置")
                                    .setOnCancelListener(new DialogInterface.OnCancelListener() {
                                      @Override
                                      public void onCancel(DialogInterface dialog) {
                                        // 如果用户不同意去设置：
                                        settingService.cancel();
                                      }
                                    })
                                    .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                                      @Override
                                      public void onClick(DialogInterface dialog, int which) {
                                        // 如果用户同意去设置：
                                        settingService.execute();
                                      }
                                    })
                                    .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                                      @Override
                                      public void onClick(DialogInterface dialog, int which) {
                                        settingService.cancel();

                                      }
                                    });

                          } else {
                            Map<String, Object> data = new HashMap<>();
                            data.put("error", "没有定位权限");
                            result.success(data);
                          }
                        }
                      })
              .start();

    } else if(call.method.equals("openMap")){

      double lat = call.argument("Lat");
      double lng = call.argument("Lng");
      String addr = call.argument("Addr");
      String nnm = call.argument("Nnm");
      String re = call.argument("Re");
      String cdno = call.argument("CDNO");

      Intent intent = new Intent(mActivity, MapActivity.class);
      intent.putExtra("CDNO", cdno);
      intent.putExtra("Re", re);
      intent.putExtra("Nnm", nnm);
      intent.putExtra("Addr", addr);
      intent.putExtra("Lng", lng);
      intent.putExtra("Lat", lat);
      mActivity.startActivity(intent);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onLocationChanged(AMapLocation aMapLocation) {
    mHandler.removeMessages(1);
    if(aMapLocation.getErrorCode() == 0){
      mAMapLocation = aMapLocation;
      if(mResult != null){
        returnResult(mResult);
      }
    } else {
      Log.d("flutter", aMapLocation.getErrorInfo()+ " code = "+aMapLocation.getErrorCode());
      if(mResult != null){
        Map<String, Object> data = new HashMap<>();
        data.put("error", aMapLocation.getErrorInfo()+ " code = "+aMapLocation.getErrorCode());
        mResult.success(data);
        mResult = null;
      }

    }
  }
}
