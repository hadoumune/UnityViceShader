using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PegionChest{
[ExecuteAlways]
public class ScreenFitter : MonoBehaviour {

	public Camera fitCamera;

	public bool isFitLeft = false;
	public bool isFitRight = false;
	public bool isFitTop = false;
	public bool isFitBottom = false;


	bool oldFitFlagL = false;
	bool oldFitFlagR = false;
	bool oldFitFlagT = false;
	bool oldFitFlagB = false;

	float defaultWidth = 0;
	float defaultHeight = 0;

	Vector2 defaultScale = Vector2.zero;
	Vector2 defaultPos = Vector2.zero;

	Vector2 screenWH{
		get{
			Ray ray = fitCamera.ScreenPointToRay(new Vector2(Screen.width, Screen.height));
			Vector2 wh = ray.origin * 2.0f;
			return wh;
		}
	}

	void apply(bool fource=false){
		if ( fource || (oldFitFlagT != isFitTop)
					|| (oldFitFlagL != isFitLeft)
					|| (oldFitFlagB != isFitBottom)
					||  (oldFitFlagR != isFitRight) ){

			Vector2 scrWH = screenWH;
			//Debug.Log("screenWH:"+scrWH);

			float newWidth = transform.localScale.x;
			float newHeight = transform.localScale.y;
			Vector2 lt = defaultPos;
			Vector2 rb = defaultPos;

			Vector2 center = defaultPos;

			if ( isFitTop ){
				lt.y = scrWH.y * 0.5f;
			}else{
				lt.y -= -defaultScale.y * 0.5f;
			}
			if ( isFitBottom ){
				rb.y = -scrWH.y * 0.5f;
			}else{
				rb.y += -defaultScale.y * 0.5f;
			}
			if ( isFitLeft ){
				lt.x = -scrWH.x * 0.5f;
			}else{
				lt.x -= defaultScale.x * 0.5f;
			}
			if ( isFitRight ){
				rb.x = scrWH.x * 0.5f;
			}else{
				rb.x += defaultScale.x * 0.5f;
			}
			center = (lt+rb)*0.5f;

			Vector3 scl = transform.localScale;
			Vector3 pos = transform.position;
			scl.x = rb.x - lt.x;
			scl.y = -(rb.y - lt.y);
			pos.x = center.x;
			pos.y = center.y;
			transform.localScale = scl;
			transform.position = pos;
		}

		oldFitFlagT = isFitTop;
		oldFitFlagL = isFitLeft;
		oldFitFlagB = isFitBottom;
		oldFitFlagR = isFitRight;
	}

	void Awake(){
		defaultScale = transform.localScale;
		defaultPos = transform.position;
	}

	// Use this for initialization
	void Start () {
		apply(fource:true);		
	}
	
	// Update is called once per frame
	void Update () {
		apply();
	}
}
}
