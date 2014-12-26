/*
Feathers
Copyright 2012-2014 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.data;
import flash.errors.IllegalOperationError;

/**
 * An <code>IListCollectionDataDescriptor</code> implementation for Vectors.
 * 
 * @see ListCollection
 * @see IListCollectionDataDescriptor
 */
class VectorListCollectionDataDescriptor implements IListCollectionDataDescriptor
{
	/**
	 * Constructor.
	 */
	public function VectorListCollectionDataDescriptor()
	{
	}
	
	/**
	 * @inheritDoc
	 */
	public function getLength(data:Object):int
	{
		this.checkForCorrectDataType(data);
		return (data as Vector.<*>).length;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getItemAt(data:Object, index:int):Object
	{
		this.checkForCorrectDataType(data);
		return (data as Vector.<*>)[index];
	}
	
	/**
	 * @inheritDoc
	 */
	public function setItemAt(data:Object, item:Object, index:int):Void
	{
		this.checkForCorrectDataType(data);
		(data as Vector.<*>)[index] = item;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addItemAt(data:Object, item:Object, index:int):Void
	{
		this.checkForCorrectDataType(data);
		(data as Vector.<*>).splice(index, 0, item);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeItemAt(data:Object, index:int):Object
	{
		this.checkForCorrectDataType(data);
		return (data as Vector.<*>).splice(index, 1)[0];
	}

	/**
	 * @inheritDoc
	 */
	public function removeAll(data:Object):Void
	{
		this.checkForCorrectDataType(data);
		(data as Vector.<*>).length = 0;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getItemIndex(data:Object, item:Object):int
	{
		this.checkForCorrectDataType(data);
		return (data as Vector.<*>).indexOf(item);
	}
	
	/**
	 * @private
	 */
	private function checkForCorrectDataType(data:Object):Void
	{
		if(!(data is Vector.<*>))
		{
			throw new IllegalOperationError("Expected Vector. Received " + Object(data).constructor + " instead.");
		}
	}
}