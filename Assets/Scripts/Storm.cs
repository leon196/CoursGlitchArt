using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Storm : MonoBehaviour
{
	public Shader shader;

	private Material material;

	void Start ()
	{
		material = new Material(shader);
		MeshFilter[] meshArray = GameObject.FindObjectsOfType<MeshFilter>();
		foreach (MeshFilter filter in meshArray) {
			filter.GetComponent<Renderer>().sharedMaterial = material;
			StoreInformations(filter);
			EnhanceBounds(filter);
		}
	}
	
	void Update ()
	{
		
	}

	void StoreInformations (MeshFilter filter)
	{
		Vector2[] sizeAndX = new Vector2[filter.mesh.vertices.Length];
		Vector2[] yz = new Vector2[filter.mesh.vertices.Length];
		Vector3 pos = filter.transform.position;
		Mesh mesh = filter.sharedMesh;
		for (int i = 0; i < sizeAndX.Length; ++i) {
			sizeAndX[i] = new Vector2(mesh.bounds.size.magnitude,pos.x);
			yz[i] = new Vector2(pos.y, pos.z);
		}
		filter.mesh.uv2 = sizeAndX;
		filter.mesh.uv3 = yz;
	}

	void EnhanceBounds (MeshFilter filter)
	{
		Bounds bounds = filter.mesh.bounds;
		bounds.size += Vector3.one * 10f;
		bounds.size *= 2f;
		filter.mesh.bounds = bounds;
		filter.mesh.UploadMeshData(false);
	}
}
